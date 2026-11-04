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

## Compact controls and widget shortcuts

Speed choices use 44-point minimum tap targets with plain rounded backgrounds.
Mode/light choices keep their symbols and readable labels. Power lives inside
the fan header with confirmed on/off text. The home header is a compact row.

ConnectedFanSnapshot now includes optional power and speed values, preserving
older saved snapshots. Widget power/speed links open Breeze and send an explicit
requested value after reloading the home. HomeConnection validates the actual
device control before sending. These shortcuts open the app; they are not
background widget commands. SDK reports still determine displayed state.

## Editable widget panels and view environments

ConnectedFansConfiguration is a WidgetConfigurationIntent. Its main fan and
three optional extra fans appear in Edit Widget. ConnectedFanQuery supplies
paired fans from shared snapshots. The timeline provider resolves saved IDs,
not a hardcoded first fan. Large widgets show reported enum controls plus
extra fan power shortcuts. Lighting and timer rows can be hidden in Edit Widget.

A sheet must receive the shared observable objects used by its content. The
widget route's NavigationStack now explicitly receives HomeConnection and
FanStore with .environment(...). The phone crash report showed an assertion
in EnvironmentValues.subscript.getter; the URL regression test opens and
closes this sheet to check the fix. Widgets still open the app to send commands.

## Background widget commands

ControlConnectedFanIntent replaces URL links on control buttons. It declares
background/dynamic runtime modes and never requests foreground continuation.
An app-only compatibility conformance preserves app-process routing; the modern
supportedModes declaration is present in both bundles. BREEZE_APP includes the
SDK implementation only in the app, so the widget never links Tuya or reads
credentials. Metadata inspection confirmed ForegroundContinuable routing with
openAppWhenRun=false. The existing app session and Keychain remain unchanged.
HomeConnection.shared serializes these actions, reloads capabilities, validates
the command, and publishes it. The widget refreshes from device reports rather
than inventing success. Open Breeze once if its account session needs attention.

Widget configuration uses Switch(.widgetFamily): small/medium show just the fan
picker, larger panels expose extra fans and lighting/timer visibility options.

## Tall iPhone widgets and the glass remote

The Notes-style tall family on iOS 27 is systemExtraLargePortrait. It is distinct
from systemExtraLarge. ConnectedFansWidget now declares both. Standard large
widgets use compact explicitly sized plain buttons and omit extra fan shortcuts;
portrait widgets provide roomier controls and the optional extra fans.

BreezeHomeTabs uses native Home and Settings tabs. Home rows put the detail
button beside a separate glass power button, avoiding nested buttons. A selected
ConnectedDevice presents the remote with sheet(item:), keeping navigation state
in one value. ConnectedDeviceView has one ScrollView on a native glassEffect
surface with transparent presentation background. The content can still scroll
for accessibility text sizes. SDK behavior and background intents are unchanged.

## Full-screen matte remote

Fan routes now use fullScreenCover(item:) from both Home and widget links.
FanRemoteHeader displays reported selected speed next to the native power
toggle. The rest remains a small, data-driven list of controls on an opaque
system background. Full-sheet glass and drawer styling were removed following
the user's preference. HomeStatusSummary counts online running fans and lights
from device reports; it does not invent weather or request location permission.

## Fan dashboard and normal page navigation

ConnectedHomeView owns a simple [String] navigation path. Home fan taps append
the device ID; widget title requests replace the path with that device. Native
NavigationStack supplies the horizontal transition, back button and edge swipe.
BreezeHomeTabs selects Home for widget navigation. Fan routes have no modal
presentation or Done button.

FanRemoteHeader displays a native power segment and decorative fan symbol.
RemoteControlTile shows each quick control's reported current setting. One
expandedControlID selects the inline choice row. DeviceControlView sends the
exact SDK values as before. The light row remains available below it.
Animations respect Reduce Motion; rename is in the Fan options menu.

## Home weather and refresh feedback

HomeWeatherCard owns LocalWeather with @State. Tapping Use my location asks
CoreLocation for one approximate foreground location. LocalWeather rounds the
coordinates, requests Open-Meteo over HTTPS, and decodes WeatherReading. No
location history, background tracking, API key, or AI service is involved.
Denied permission and failed requests show retry text; weather is optional and
does not block fan controls. Open-Meteo attribution is visible in the card.
https://open-meteo.com/en/docs explains the current weather fields.

HomeStatusSummary counts reported power and light states of online devices.
The Home header animates fan blades only while SDK work is busy, respecting
Reduce Motion. The remote uses equal flexible columns for short selector rows
so four light choices occupy the entire width. Accessibility sizes retain an
adaptive grid for readable labels.

## Home summary without weather

Weather was removed at the user's request. The Home List now uses one VStack
row containing the home name and total fans, a divider, and HomeStatusSummary.
There is no weather service or weather-related location request in the app.
CurrentWiFi remains a separate setup helper, disabled for Personal Team builds.
The earlier weather section above documents a removed implementation.

## Live Siri actions, November 4

App/Siri contains five small AppIntent structs. Each takes ConnectedFanEntity;
the absolute-speed action also takes an integer. They execute in the app process
so they can use the SDK session. Widget commands retain their existing routing.
BreezeShortcuts advertises five actions with application-name phrases.
ConnectedFanQuery implements EntityStringQuery so Siri can resolve fan names.
SiriSettingsView stores only the chosen default fan ID in the shared preferences.

HomeConnection.changeSpeed first loads a fresh home report while holding the
same busy gate as widget commands. FanSpeedStep sorts numeric enum choices and
moves one supported step. At a limit it returns a spoken explanation without
sending a command. Unknown reports fail safely; off fans must be turned on first.
Snapshots are used for fan discovery, never for relative speed decisions.

Legacy demo SwiftUI views, widget files and intents are excluded from both
compiled targets by generate_project.py. FanStore remains as a historical
model/test exercise. It is no longer created by the app or advertised to Siri.
