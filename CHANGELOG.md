# 0.8.2

**Reminder**: You can access the Chattery settings either through the Addon Compartment on the minimap, or by using the `/chattery` command.

## Added
- Auto grammar settings now apply to messages shorter than 255 characters long
	- This excludes the RP formatting setting

## Fixed
- Fixed an issue that caused long messages with no spaces would throw errors and fail to send
- Fixed an issue where messages could end up over the max message length and fail to send
- Fixed an overflow error that would be thrown if you tried to open the chat box while messages were sending
