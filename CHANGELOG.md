# 0.8.5

**Reminder**: You can access the Chattery settings through the minimap button, the addon compartment, or by using the `/chattery` command.

## Fixed
- Chat links are no longer hungry enough to eat spaces in your message
- Messages should no longer have an extra space added to the end
	- This would've manifested as your character playing the wrong "talking" animation when talking in `/say` and related channels
- Convinced the auto-capitalization feature to chill out and not erroneously capitalize the second letter of your message

# 0.8.4

## Added
- A character count display to the chat frame edit box
	- This will display the length of the current message and the message size limit, if present
	- This can be disabled in the settings

## Fixed
- You can no longer send messages that Chattery can't handle to custom/global channels (i.e. Trade, General)
