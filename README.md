# SpiceCompanion
The official companion app to SpiceTools. This app allows for remotely
controlling and managing a running instance with the API enabled and
configured.

## Features
- Manage and insert cards
- Scan cards using NFC
- Virtual Keypad/Scanner
- Live Patches: Enable/Disable hex edits on the fly
- Online patch list download
- Tons of preset patches, ability to add custom ones
- View/Override/Press Buttons/Analogs/Lights on the fly
- Game status overview
- Exit your games remotely
- Dark mode (optional)

## Requirements
- SpiceTools
- Android 4.4+
- NFC (optional)

A port to iOS is possible and being considered.

## How to use with SpiceTools
In your batch file setup to for usage with SpiceTools, enable the `-api` and
`-apipass` parameters with your desired port and password, respectively. After
you've done that, add your server in the app, connect to it, and you're good
to go!

Example usage of the parameters:
`-api 1337 -apipass changeme`
