# Learning SwiftUI through Breeze

You do not need to understand widgets or Siri first. Start with the app screen.

The new app opens `ConnectedHomeView`, which switches between private SDK setup,
account sign-in, home creation and the real device list. `SDKSetupView` has two
secure fields and calls `saveSDKSettings`; `SDKKeychain` saves those settings
using Apple's Security framework. The vendor integration is in `HomeConnection`.
It uses `async` methods to keep the button handlers short. Vendor completion
handlers are bridged with checked continuations; this is the one advanced area
you can study after understanding the views.

The original `HomeView` and `FanStore` are still a separate demo, accessible from
the setup screen's demo button. The step-by-step lesson below follows that simpler
demo first. Live device controls are in `ConnectedDeviceView`/`DeviceControlView`.
The app adds no AI features or AI frameworks.

## 1. Read `Fan.swift`

`Fan` is a **struct**: a group of related values. `isOn` is a `Bool`, `speed` is an
`Int`, and `name` is a `String`. `Identifiable` gives SwiftUI a stable way to tell
two fans apart. The `id` stays the same even if a setting changes.

`summary` is a **computed property**. It returns a short description from the
current values, instead of storing another string that could get out of date.

`Codable` lets Apple's `JSONEncoder` and `JSONDecoder` save and read the struct.
`FanMode` is an **enum**: a fixed set of choices that prevents misspelled modes.

## 2. Open `HomeView.swift`

A view's `body` describes what should appear on screen. `VStack` arranges views
vertically; `HStack` arranges them horizontally. `Text` renders text. Modifiers
such as `.font(...)` or `.padding(...)` configure a view.

`NavigationStack` provides Apple's navigation behavior. `NavigationLink(value:)`
pushes a fan ID; `.navigationDestination` turns that ID into `FanDetailView`.

`ForEach(store.fans)` creates one card per fan. The stable `Fan.id` lets SwiftUI
update the correct card when settings change.

## 3. Follow one button

Read the power button in `FanCardView.swift`:

```swift
Button(fan.isOn ? "Turn off" : "Turn on", systemImage: "power") {
    store.perform {
        try store.setPower(id: fan.id, isOn: !fan.isOn)
    }
}
```

The `? :` expression chooses the title. `!` flips a Boolean, so an on fan gets
an off command. The closure inside `Button` runs when tapped.

`setPower` can throw an error, so it is called with `try`. `perform` catches
errors and sets `errorMessage`, which the screen presents in an alert. This keeps
error handling out of every individual button.

## 4. Understand the store

`FanStore` is a **class** because the views share the same instance.
`@Observable` tells SwiftUI to watch values read from it. `@MainActor` keeps its
UI-facing changes on the main actor.

In `BreezeApp`, `@State` owns the store for the lifetime of the app's view.
`.environment(store)` passes it down through the view hierarchy. A child gets
the store with `@Environment(FanStore.self)`.

The data flow is:

```text
Tap a button
    → FanStore changes a Fan
    → FanStorage saves it
    → SwiftUI sees the changed fans array
    → The affected view redraws
```

`private(set)` means views can read `fans`, but only the store can replace it.
That keeps saving and validation in one place.

## 5. Look at a small screen

`LightPickerView` is a good next file. It has four choices, a button for each,
and a checkmark next to the current choice. It uses a native `List`, with no
custom gesture handling or navigation machinery.

`SpeedControlView` uses an adaptive grid so buttons can wrap when space is
limited. Text styles like `.headline` scale with the user's text-size setting.

## 6. Learn persistence

`FanStorage` encodes each fan to JSON and puts it in `UserDefaults`. This is
appropriate for a handful of demo preferences. It is not a password store.

The App Group suite lets the app and widget access the same demo preferences.
Because the widget is a separate process, the app refreshes when it becomes
active again. The store reloads the latest data before making a change.

## 7. Only then explore Siri

`FanEntity` tells Shortcuts what a fan looks like in its picker. `FanQuery`
supplies the available fans. `SetFanSpeedIntent` declares the fan and speed as
parameters, then calls the same store method as the on-screen button.

`BreezeShortcuts` advertises a few suggested phrases. An App Intent is an action
Apple can run; it does not itself connect to a physical fan or add HomeKit.

## 8. Widgets are another small view

`FanWidgetConfiguration` holds the user's selected fan. The provider reads its
saved state and supplies a timeline entry. `FanWidgetView` displays that entry.
Its buttons run App Intents rather than `onTapGesture` handlers.

## A few small exercises

1. Change the home screen subtitle in `HomeView`.
2. Change the accent from `.teal` to another system color.
3. Add a room label to the detail screen.
4. Add a new test confirming a light level of 0 turns the demo light off.
5. Read the timer test: advance its supplied date rather than waiting two hours.

Keep changes small, run the app, and watch what changes. Start with views before
opening the intent or widget files.

## Wi-Fi detection and a little motion

`CurrentWiFi.swift` is a small observable helper. It asks iOS for permission,
then uses `NEHotspotNetwork.fetchCurrent` to read the connected Wi-Fi name.
It never requests location coordinates or reads your Wi-Fi password.
`AddFanView` watches `isChecking`; when the lookup finishes, it fills in the name.
Manual entry still works if permission is denied. During AP pairing, we keep
the home Wi-Fi name even after the phone joins the fan's temporary hotspot.
Your current free Apple Personal Team cannot sign the Wi-Fi capability, so
`isAvailable` is false in this build: the lookup and permission request stay off.
See `CONNECTING.md` for enabling it with an eligible developer team.

`FanConnectionHeader.swift` is a reusable view with a title, subtitle and SF Symbol.
The system's `.symbolEffect(.rotate)` animates the fan while connecting.
`accessibilityReduceMotion` switches that effect off when requested in Settings.
The form uses `.animation(_:value:)` to animate only pairing and mode changes.

## Following the real pairing stages

Read `PairingStage` and `PairingProgress` first: they are plain Swift values.
The progress type stores a stage, explanation, deadline, and short history.
`PairingProgressTests` supplies fixed dates, so it checks timeouts instantly.
`HomeConnection` updates these values from SDK callbacks and has a separate
watchdog so a missing cloud callback cannot leave the screen spinning forever.
`PairingStatusView` uses `TimelineView` to display the time left; it never guesses
a completion percentage. `PairingGuideView` displays the supplied remote image
and distinguishes the documented fast-blink instructions from the AP flow.

## Live control design and connected widgets

`DeviceControlView` renders bool values as a Toggle, enum choices as visible
icon buttons, and numeric values as a Stepper. It sends the original SDK value.
`DeviceControl+Presentation` keeps friendly labels and SF Symbols separate from
network commands. `ConnectedDeviceView` owns only the rename alert state;
`HomeConnection.renameDevice` calls the SDK and reloads the device report.

`ConnectedFanSnapshot` stores display data in the App Group. After SDK device
updates, Breeze saves snapshots and asks WidgetKit to reload. The Connected fan
widget shows the first connected fan's last report with its update time and opens
that fan's controls in the app. It does not send background device commands.
The original demo widget remains separately named Demo fan.
