# Breeze

A native SwiftUI remote for paired Orient fans. Built for personal use and learning.
Pairing, live controls and background widget power commands have been verified
with the real fan. Siri actions now use the same connected-device service.

## Connect a fan

Open Breeze, configure your personal Tuya SDK settings if needed, sign in,
create a home, and tap +. Follow the remote pairing guide and use a 2.4 GHz home
network. The basic device SDK uses its cloud for login, pairing and control;
this is not an offline-only controller. Credentials stay in the app's Keychain.
Widgets receive display snapshots, never credentials or Wi-Fi passwords.

## Siri and Shortcuts

Open Breeze once after installing. Go to Settings → Siri & Shortcuts and choose
a default fan. With only one fan it is selected automatically; otherwise Siri
asks which fan unless you name one or select a default.

Available live actions:
- Turn on fan
- Turn off fan
- Set fan speed
- Increase fan speed
- Decrease fan speed

Try “Hey Siri, turn on the fan in Breeze” or “Hey Siri, increase fan speed in
Breeze”. Automatic App Shortcut phrases include the app name. For an exact
phrase such as “Turn on Pawan fan”, create a shortcut in Apple's Shortcuts app,
add the matching Breeze action, select the fan, and give the shortcut that name.

Relative speed reads the current device report before moving one supported
level. It respects minimum/maximum and asks you to turn on an off fan first.
Offline fans, missing login and unsupported values return errors. A successful
SDK command is not a measurement of physical blade movement. Spoken Siri
recognition still needs testing on the user's phone and Siri language.

This uses Apple's App Intents, not a separate AI model or AI service.
Demo entrypoints, widgets and actions are no longer shipped. Legacy demo source
is retained for learning and excluded by the project generator.

## Widgets

Choose Breeze → Connected fan in the widget gallery. Edit Widget selects its
fan. Small provides power; medium adds speed; large and extra-large sizes offer
mode, timer and lighting. Extra Large Portrait supports the tall iPhone panel
and optional extra fan power buttons. Buttons run background intents; the title
opens the fan's page. iOS controls refresh timing.

## Open and learn

Open Breeze.xcworkspace in Xcode 27.2 or later. Select Breeze and your phone or
an iOS 27+ simulator. Choose your signing team for app and widget targets.
The vendor SDK lives in Breeze/Connectivity/HomeConnection.swift. App/Siri has
five small, readable actions. BreezeShortcuts supplies phrases; ConnectedFanQuery
resolves names and the default fan. SiriSettingsView explains configuration.

LEARNING.md contains the implementation history, including superseded designs.
No WeatherKit, weather provider or weather location tracking is included.

## Verification and maintenance

Run `swift test` for shared model tests. Run BreezeUITests in Xcode for setup,
Siri settings, fan controls and widget routes. Simulator tests cannot establish
spoken Siri recognition or physical fan response.

After adding/removing Swift files run `python3 scripts/generate_project.py`, then
`pod install`. Build the workspace, not the standalone project. The generator
preserves your signing team and excludes legacy demo surfaces and intents.
