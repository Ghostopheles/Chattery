# 0.8.3

**Reminder**: You can access the Chattery settings through the minimap button, the addon compartment, or by using the `/chattery` command.

## Added
- A shiny new minimap button. Can be toggled off in the settings, or with a right-click

# 0.8.2

## Added
- Auto grammar settings now apply to messages shorter than 255 characters long
	- This excludes the RP formatting setting

## Fixed
- Fixed an issue that caused long messages with no spaces would throw errors and fail to send
- Fixed an issue where messages could end up over the max message length and fail to send
- Fixed an overflow error that would be thrown if you tried to open the chat box while messages were sending
- Fixed a catastrophic explosion that could occur when sending multi-part messages while in a delve
