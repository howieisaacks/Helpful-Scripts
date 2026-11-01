#!/bin/zsh --no-rcs

export PATH=/usr/bin:/bin:/usr/sbin:/sbin
set -euo pipefail

:<<'INFO'
----------------------------------------
TITLE: User change password
VERSION: 1.0
PURPOSE: Make it easy for a user to change their Mac password.

11/1/2026 | Howie Canterbury
----------------------------------------
INFO

# INTERFACE COLORS - Used in Swift Dialog - Colors below were taken from the Jamf visual style guide
# https://jamf.bynder.com/guidelines/guide/09e4aa04-da69-42b0-8fbc-76548a3fc9ed
blue_violet="#5050BC"
haiti="#100F2F"
black="#181A1C"
celtic_blue="#056AE6"
freshmaker_green="#50DEAF"
deep_sea="#00348A"
white="#F9F7F1"

# USER VARIABLES
current_user=$(stat -f '%Su' /dev/console)
current_uid=$(id -u "$current_user")

# OPEN USER ACCOUNT
# ------------------------
open_user_account() {
    local settings_url="x-apple.systempreferences:com.apple.Users-Groups-Settings.extension?showinfo*user:${current_user}"
    
    if [[ -z "$current_user" || "$current_user" == "root" || "$current_user" == "loginwindow" ]]; then
        echo "No valid logged-in user was detected."
        exit 0
    fi
    
    # Launch user account settings
    launchctl asuser "$current_uid" \
    sudo -u "$current_user" \
    open "$settings_url"
}

# CHANGE PASSWORD PROMPT
# ------------------------
change_password_dialog() {
    local dialog_bin="/usr/local/bin/dialog"
    
    dialog_cmd=(
    --moveable
    --ontop
    --appearance "light"
    --bannerimage "colour=${deep_sea},nogradient"
    --bannerheight "50"
    --bannertitle "Change your Mac login password"
    --titlefont "size=24,weight=light,colour=${white}"
    --image "https://raw.github.com/howieisaacks/Images/main/Change-Password.png"
    --image "https://raw.github.com/howieisaacks/Images/main/Password-Change.png"
    --message "Click **Change Password** to launch your account settings and change your Mac login password."
    --noicon
    --height "400"
    --width "800"
    --button1text "Change Password"
    --button2text "Cancel"
    --buttontextsize "14"
    --buttonsize "large"
    )
    
    "${dialog_bin}" "${dialog_cmd[@]}"
}

# MAIN FUNCTION
# ------------------------
main() {
    local dialog_result
    
    # Launch Dialog
    if change_password_dialog; then
        dialog_result=0
    else
        dialog_result=$?
    fi
    
    case "${dialog_result}" in
        0)
            print "User clicked Change Password"
            open_user_account
        ;;
        2)
            print "User clicked Cancel"
            return 0
        ;;
        *)
            print "Dialog exited with unexpected code: ${dialog_result}"
            return 1
        ;;
    esac
}

# RUN
# -----------------------------------
main "$@"

# TEST A FUNCTION
# -----------------------------------
