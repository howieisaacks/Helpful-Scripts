# MDM Erase Mac (Jamf Pro)

If a user is not an admin on a Mac, they cannot use the Erase All Contents and Settings feature in macOS. This script was created to use the MDM remote wipe command from the Jamf Pro API. Swift Dialog is used for allowing the user to erase their Mac.

The script uses Jamf Pro parameters for your API credentials. You will need an API client that has the appropriate rights set to send the remote wipe command. Enter your Jamf Pro server URL in the script. Use parameter 4 for the API client ID and parameter 5 for the API client secret.

The happy and sad Mac icons are my own creation. You are welcome to use them. They are linked in the Swift Dialog functions.

Create a policy in Jamf Pro using this script and make it available in Self Service. The process starts with this Dialog window. The user can choose to continue with the erase or cancel.

![Erase Mac start](https://raw.github.com/howieisaacks/Images/main/Erase-Mac-Start.png)

If they decide to continue with the erase, this Dialog window is shown. A 10-second timer will terminate the window, and then the remote wipe command is sent.

![Erase confirmed](https://raw.github.com/howieisaacks/Images/main/Erase-Mac-Confirmation.png)

If the user decides to cancel the erase (Maybe they clicked the policy by mistake or changed their mind), this window is shown. A 10-second timer will close the window.

![Canceled erase](https://github.com/howieisaacks/Images/blob/main/Canceled-Erase.png)




# User Change Password Prompt

The idea behind this script was a concern expressed by a member of my support team who mentioned that users may not know how to change their Mac password if they want to. 
We are moving from Platform Single Sign-on using password sync with Entra ID to Secure Enclave. After the switch, users will be able to change their Mac login password.

This script uses Swift Dialog to guide the user to where they need to go to change their Mac password. It will auto-launch their user account settings.

![Swift Dialog prompt to change Mac login password](https://raw.github.com/howieisaacks/Images/main/Change-Mac-Password.png)

![User account settings](https://raw.github.com/howieisaacks/Images/main/Change-Password.png)

![Change password](https://raw.github.com/howieisaacks/Images/main/Password-Change.png)
