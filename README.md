# Breeze

A small native SwiftUI app for learning and exploring better ceiling-fan controls.

**Orient pairing and live controls are working. Connected-fan widgets now use
background App Intents. Power on/off was verified on the real Pappu fan through
iPhone Mirroring while the Home Screen remained visible. Demo Shortcuts remain
separate from live controls.**

## Personal use and connectivity

This is a personal development build. It includes no AI features, AI SDKs, model
inference, voice generation, or chat. No on-device AI is needed for the controls.
The vendor's basic connectivity SDK still uses its cloud for account login and
pairing tokens; this is not an offline-only implementation.

On the updated iPhone app:

1. On your Mac, open Tuya Developer Platform → Breeze → Get Key → iOS.
2. Paste the AppKey and AppSecret into Breeze's **Connect Breeze** screen on the
   phone. They are stored in that phone's Keychain; keep them out of chat/logs.
3. Create a Breeze device account with an email verification code, or sign in to
   an existing Breeze device account. This is separate from an Orient login.
4. Create a home, tap **+**, and prepare one fan for pairing using its manual.
5. Enter the home 2.4 GHz network's name and password. In AP mode Breeze requests
   its token first, then asks you to join the fan's hotspot in Settings and return.
6. After successful activation, control the device using its own reported schema.

Existing fan ownership may require unbinding/re-pairing. Test one fan first. The
new screens never report success until the SDK returns a device activation result.
Passwords and pairing tokens are not logged or stored in shared demo preferences.

The live controller is `Breeze/Connectivity/HomeConnection.swift`. The device SDK
is intentionally isolated from the native SwiftUI screens. These are real SDK
calls, but compilation alone does not establish hardware compatibility. Controls
display the fan's reported state rather than treating command submission as a
confirmed physical change.

## Open and run

1. Open `Breeze.xcworkspace` in Xcode 27.2 or later (the workspace includes Pods).
2. Select the **Breeze** scheme and an iPhone simulator running iOS 27 or later.
3. Press **Run** (⌘R).

For a physical phone, select your development team in **Signing & Capabilities**
for both Breeze and BreezeWidgets. Use available bundle identifiers and register
the same App Group on both targets. Update `FanStorage.appGroup` and
`Configuration/Breeze.entitlements` together if the group name changes. App Group
provisioning depends on your Apple developer account. Code signing is intentionally
not tied to someone else's team.

## Demo controls you can still explore

- Two demo fans, saved between launches.
- Power, six demo speeds, Normal/Turbo/Sleep/Breeze/Reverse modes.
- Independent light settings: Off and Levels 1–3.
- Demo countdowns: 2, 4, 6, and 8 hours.
- Small and medium interactive Home Screen widgets with a fan selector.
- Five parameterized App Intents in Shortcuts: power, speed, light, mode, timer.
- Widget links that open the matching fan's detail screen.
- Native light/dark appearances and text that follows Dynamic Type.

The six-speed range is provisional: the screenshots did not show the full speed
picker. No color-temperature controls are invented. There are no recurring
schedules yet: reliable execution requires a device/cloud/always-on bridge timer,
not an iPhone app waiting in the background.

### Siri and widgets

After installing and opening Breeze once, search for **Breeze** actions in the
Shortcuts app. Add **Set Demo Fan Speed**, select a fan and speed, and save a
shortcut named something like **Bedroom breeze**. Invoke that shortcut by name.
App Shortcuts also advertises “Set fan speed in Breeze”; Siri can ask for missing
parameters. Arbitrary HomeKit-style voice parsing is not promised.

Add **Breeze → Connected fan** from the widget gallery, then Edit Widget to
choose a paired fan. Small has power; medium adds speed; large and supported
extra-large sizes add mode, timer, and light. The iOS 27 Extra Large Portrait
family provides the tall iPhone panel and optional extra fan power shortcuts.
Edit options are filtered by size. Buttons use background App Intents; tapping
the widget's title still opens its controls. The separate Demo fan widget uses
local examples. Widget refresh timing is controlled by iOS.

## Learn the code

Start with [LEARNING.md](LEARNING.md). This intentionally uses structs, a single
observable demo store, small views and standard SwiftUI controls. The vendor's
device SDK is isolated in the connectivity area. There are no repository/service/use-case layers or dependency
injection frameworks to learn first.

## Hardware verification still needed

The screens establish controls, not protocol IDs or credentials. The next hardware
milestone is an authenticated **read-only status request** to one fan. We then
verify a single power/speed command and map its reported status back to `Fan`.

The chosen route is the official basic device SDK and direct pairing, not an
account link to another remote-control app. Wi-Fi connectivity alone does not
prove compatibility. Pairing and command submission occur only when the user
explicitly starts them in Breeze. No credentials are extracted from Orient.

`FanStore` remains isolated demo state. `HomeConnection` owns the vendor SDK,
pairing and live device controls. Apple Home/HomeKit exposure is a separate bridge
integration, not a consequence of adding App Intents. ControlConnectedFanIntent
runs validated commands through the shared HomeConnection in the app process
without requesting foreground presentation. Widgets never receive SDK secrets.

## Tests and project maintenance

Run core behavior tests on the Mac:

```sh
swift test --scratch-path build/swift-tests
```

Build app and widget without signing:

```sh
xcodebuild -workspace Breeze.xcworkspace -scheme Breeze \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

UI test source is included in `BreezeUITests`; run it on a working iOS 27+
simulator. These tests cannot establish that Siri recognizes speech or that
an Orient fan responds. Widget and Siri behavior need on-device validation.

After adding/removing a Swift file, run `python3 scripts/generate_project.py`,
then `pod install` to restore SDK integration. Normal Swift edits need neither.
The generator preserves selected signing teams. The icon is drawn by
`swift scripts/create_icon.swift`.

## Deliberate limits

The demo preferences are intentionally simple. Separate processes read the latest
saved fan before each change, but simultaneous changes are not an atomic
transaction. A real device controller will need serialized commands and device
state reconciliation. Demo timers reconcile on refresh, not via guaranteed
background execution. This is a learning foundation, not a finished hardware
integration or an App Store release.
