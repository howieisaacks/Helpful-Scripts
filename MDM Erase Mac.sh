#!/bin/zsh --no-rcs

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

:<<INFO
----------------------------------------
TITLE: MDM Erase Mac
VERSION: 1.0
PURPOSE: Provide the ability for easy erase and reinstall of Macs using a Self Service policy
The Jamf Pro API is used to run the MDM remote wipe command.

5/14/2026 | Howie Canterbury
----------------------------------------
INFO

# GLOBAL VARIABLES
#---------------------------------
currentUser=$(/usr/bin/stat -f "%Su" /dev/console)
log_file="/private/var/log/${script_name:r}.log"
dialog_bin="/usr/local/bin/dialog"
dialog_command_file="/var/tmp/dialog.log"

# JAMF PRO API PARAMETERS
# Parameter 4: API client ID
# Parameter 5: API client secret
#################################################

# JAMF PRO API LOGIN
#---------------------------------
url="YOURSERVER_URL"
client_id="$4"
client_secret="$5"

# JAMF PRO API AUTH FUNCTION
#---------------------------------
jamfAPI_auth() {
	response=$(curl --silent --location --request POST "${url}/api/oauth/token" \
		--header "Content-Type: application/x-www-form-urlencoded" \
		--data-urlencode "client_id=${client_id}" \
		--data-urlencode "grant_type=client_credentials" \
		--data-urlencode "client_secret=${client_secret}")
	token=$(echo "$response" | plutil -extract access_token raw -)
	token_expires_in=$(echo "$response" | plutil -extract expires_in raw -)
	token_expiration_epoch=$(($current_epoch + $token_expires_in - 1))
}

# VERIFICATION DIALOG
# Display Dialog to verify that the user wants to erase. Provide a Cancel button in case they chicken out.
#---------------------------------
verify_dialog() {
	"$dialog_bin" \
	--moveable \
	--ontop \
	--bannerimage "colour=red,nogradient" \
	--bannerheight "50" \
	--bannertitle "Erase all content and settings" \
	--titlefont "colour=white,size=24,weight=regular,shadow=1" \
	--message "### Click Erase to erase all content and settings on this Mac.<br><br>This process **cannot be stopped**. Please check that your data is stored in OneDrive or has been backed up.<br><br>**You may need to connect to ethernet to allow the Mac to connect to Apple to activate macOS.**<br><br>To cancel the erase, click **Cancel**." \
	--icon "https://raw.github.com/howieisaacks/icons/main/Erase-Assistant.png" \
	--button1text "Erase" \
	--button2text "Cancel" \
	--buttonsize "large" \
	--appearance "light"
	
	dialog_result="$?"
}

# ERASE DIALOG
#---------------------------------
erase_dialog() {
	"$dialog_bin" \
	--ontop \
	--small \
	--bannerimage "colour=red,nogradient" \
	--bannerheight "50" \
	--bannertitle "Erasing this Mac..." \
	--titlefont "colour=white,size=24,weight=regular,shadow=1" \
	--message "This Mac will now be erased.<br><br> **You may need to ethernet to activate macOS.**<br><br>Erase will begin in a few seconds." \
	--icon "https://raw.github.com/howieisaacks/icons/main/Sad-Mac.png" \
	--iconsize "200" \
	--appearance "light" \
	--button1text "OK" \
	--button1disabled \
	--timer "20"
	
	erase_result="$?"
}

# CANCELED DIALOG
#---------------------------------
canceled_dialog() {
	"$dialog_bin" \
	--ontop \
	--small \
	--bannerimage "colour=green,nogradient" \
	--bannerheight "50" \
	--bannertitle "Erase canceled" \
	--titlefont "colour=white,size=24,weight=regular,shadow=1" \
	--message "You have canceled erasing this Mac. Click **OK** to terminate this process." \
	--icon "https://raw.github.com/howieisaacks/icons/main/Happy-Mac.png" \
	--iconsize "200" \
	--appearance "light" \
	--button1text "OK" \
	--timer "20"
	
	cancel_result="$?"
}

# RUN REMOTE WIPE COMMAND
#---------------------------------
wipe_mac() {
	# Start authenticated Jamf API session
	jamfAPI_auth
	
	# Computer information
	serial=$(/usr/sbin/system_profiler SPHardwareDataType 2>/dev/null | /usr/bin/awk -F': ' '/Serial Number/ {print $2}')
	jss_ID=$(curl -G "${url}/api/v1/computers-inventory" --data-urlencode "filter=hardware.serialNumber=="${serial}"" --data-urlencode "section=GENERAL" --header "Authorization: Bearer ${token}" --header "Accept: application/json" | jq -r '.results[0].id')
	
	# Erase commannd
	curl --request POST "${url}/api/v1/computer-inventory/{$jss_ID}/erase" --header "Authorization: Bearer ${token}" --header "Content-Type: application/json" --header "Accept: application/json"
}

# MAIN FUNCTION
# This is where the magic happens!
#---------------------------------
main() {
	# Display dialog to verify erase
	verify_dialog
	
	# Process input from user
	case "$dialog_result" in
		0)
			# Display erase Dialog
			erase_dialog
			case "$erase_result" in
				0)
					# Run wipe command
					wipe_mac
				;;
				4)
					# Run wipe command
					wipe_mac
				;;
			esac
		;;
		2)
			echo "User canceled erase"
			# Display canceled Dialog
			canceled_dialog
			sleep 2
			# Ensure Dialog quit
			if pgrep -x dialog > /dev/null; then
				echo "quit:" >> /var/tmp/dialog.log
			fi
		;;
	esac
			
}

# RUN ALL FUNCTIONS
# -----------------------------------
main "$@"   