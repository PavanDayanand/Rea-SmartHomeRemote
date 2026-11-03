# Verification — 2026-11-03

Scope: readable SwiftUI demo app, interactive widget extension, App Intents,
shared demo preferences, and learning documentation. No physical fan integration.

- Xcode 27.2 / Swift 6.4.2: generic iOS Simulator build succeeded for app and
  embedded widget. App Intents metadata and three phrase-training outputs were
  generated. No Swift compilation warnings were reported in the app/widget build.
- Swift Testing: 8 core behavior tests passed on macOS. Covers persistence,
  validation, independent light/power, timer expiry/cancellation, and sequential
  changes by separate stores. Does not prove concurrent process safety.
- XCTest: 1 simulator UI test passed on iPhone 17 / iOS 27.0. Checks visible demo
  disclosure, navigation, selecting speed 3, selected accessibility trait, and
  power off. Result: `build/BreezeUITests-final.xcresult`.
- Initial UI assertions failed because `LabeledContent` combines its label/value
  in the accessibility tree. Inspected the recording, persisted state and actual
  tree; changed the assertion to the observed combined label. Final run passed.
- Structural check: all 30 Swift sources referenced by the Xcode project;
  extension embedded; app and extension have extracted App Intents metadata.
- `plutil -lint`: project file, both Info plists and shared entitlement passed.
- Simulator runtime initially unavailable; became available after service
  initialization. No simulator/runtime reinstall was needed.

Unverified: physical Orient device access, live Tuya protocol/data-point mapping,
Siri speech recognition, signed-device App Group provisioning, and widget-gallery
interaction. Six speeds are explicitly provisional demo data. Timer behavior is
refresh-based demo reconciliation, not guaranteed iOS background execution.

VERDICT: PASS

## Create Home observation fix — 2026-11-03

- User reported that Create home stays on the same screen after account creation.
- `hasHome` previously read an observation-ignored vendor object. Added an
  observable selected home ID, published after home details load, so SwiftUI
  can transition to the device list even when the default name is unchanged.
- Creation first checks for an existing server home to recover prior successful
  attempts without creating another home.
- Signed generic iOS build passed: `build/home-transition-fix-build.log`.
- Installed on the physical iPhone successfully, database sequence 2892:
  `build/home-fix-install.json`. On-phone Create Home behavior still needs the
  user's confirmation; no live fan pairing is claimed.

This verdict applies to the scoped demo implementation and checks above, not to
hardware readiness or App Store release readiness.

## Physical iPhone delivery — 2026-11-03

- Selected the user's existing development team for app and widget in Xcode.
  Xcode refreshed the App Group provisioning for both targets.
- Signed Debug device build succeeded for the paired iPhone 17 Pro / iOS 27.2.
- `devicectl device install app` succeeded for `com.pavand.breeze`, including the
  embedded widget extension. Evidence: `build/device-install.json`.
- Automatic launch was denied because the phone was locked. The user must unlock
  the phone and open Breeze; no successful physical launch is claimed.
- The generator now preserves teams selected in Xcode. Validated regeneration
  in an isolated temporary copy: all four app/widget signing configurations kept
  their team selection.
- Device build reported an iPad interface-orientation warning; installation was
  successful. No app logic changed during device delivery.

VERDICT: PASS

Device installation passed. Physical launch, Siri, widget interactions, and actual
fan control remain unverified.

## SDK connection implementation — 2026-11-03

- Integrated the user's local security package and basic ThingSmartHomeKit SDK
  7.11.0.1 through the version range in the portal-generated Podfile.
- Resolved 28 pods. No dedicated AI, voice or LLM pod appears in `Podfile.lock`;
  the app implements no AI/model calls. The SDK still uses vendor cloud services
  for accounts and activation tokens.
- Device compilation and signing succeeded with actual SDK headers. Replaced
  deprecated verification-email API and matched delegate optionality.
- Added private in-app SDK setup backed by Apple Keychain, account creation/login,
  home creation, AP/EZ activation, schema-based device controls and SDK state
  callbacks. No real fan activation or control has been performed.
- AP flow requests its token before the user joins the device's hotspot. Tokens
  and Wi-Fi passwords are kept in memory and cleared when pairing ends.
- Two simulator UI tests passed in `build/ConnectionUITests-explicit.xcresult`:
  setup/demo isolation and the original demo navigation/speed/power checks. Both
  use flags that skip SDK initialization and remote account access.
- Xcode's simulator test planner omitted implicit Pods dependencies. Added the
  explicit Pods subproject dependency in `Podfile`; the subsequent build/tests
  passed. Old failures are retained in build logs for diagnosis.
- Simulator screenshot visually reviewed: `Screenshots/Connect-Breeze.png`.
- The latest physical-device delivery attempt stopped because the iPhone became
  unavailable. User was asked to reconnect/unlock it. Do not claim this update is
  installed until a new successful installation result is recorded.
- The final signed generic iOS build succeeded after the last app/configuration
  changes. Installable output: `build/ConnectedDeviceBuild/Build/Products/Debug-iphoneos/Breeze.app`.

VERDICT: PASS

This verifies compilation and the described setup UI only. Live account login,
pairing, reported device capabilities and actual fan commands need a hardware
test. Live Siri/widget support remains unimplemented; existing actions/widgets
are explicitly demo-only.

## Connection update delivered — 2026-11-03

- After the user reconnected the phone, the initial transfer failed with a
  CoreDevice interrupted connection. A fresh device-details query then confirmed
  an active paired network tunnel.
- A new installation attempt succeeded for the SDK-backed Breeze build. Evidence:
  `build/connection-device-install-recovered.json`, database sequence 2884.
- `devicectl device process launch` then succeeded for `com.pavand.breeze`.
  Evidence: `build/connection-device-launch.json`.
- This confirms installation and process launch on the physical iPhone. Account
  setup, actual pairing and hardware control still require the user's on-phone
  configuration and a single-fan test.

VERDICT: PASS

## Wi-Fi lookup and native pairing design — 2026-11-03

- Added CurrentWiFi using public Core Location authorization and NEHotspotNetwork
  APIs, manual entry fallback, and protection for home SSID during AP pairing.
- Added a shared native fan header and Reduce Motion aware connecting symbol
  effect and form transitions. Added beginner notes in LEARNING.md.
- Xcode rejected Access Wi-Fi Information for the user's free Personal Team.
  Evidence: build/wifi-capability-build.log. Automatic detection is therefore
  NOT available in the installed build. It requires an eligible Apple developer
  team and generator option --enable-wifi-info. No location prompt occurs in
  the Personal Team configuration. Live Wi-Fi detection remains unverified.
- Fixed the project generator to preserve location purpose text and optional
  capability, and separated widget entitlements. Built-app plist checks passed.
- Final signed device build passed: build/wifi-personal-team-build.log.
- Two existing UI regression tests passed with zero failures:
  build/WiFiPersonalTeamUITests.xcresult. They cover setup/demo separation
  and demo controls, not real Wi-Fi lookup or live pairing animation.
- Final installation succeeded, sequence 2908:
  build/wifi-personal-team-install.json.

VERDICT: PASS

Delivered design and supported manual-entry build verified. Requested automatic
Wi-Fi detection is blocked by Apple's Personal Team capability restriction.

## Pairing stall recovery and remote guide — 2026-11-03

- User reported failure with both blink rates. No live device trace establishes
  the exact AP failure. Found concrete code gaps: no token timeout, no intermediate
  activator delegate handling, no security-level AP home-Wi-Fi continuation,
  cloud home refresh on foreground while using a no-internet fan hotspot, and
  an offered EZ path without required multicast signing.
- Added separate token/hotspot/activation deadlines and foreground checks;
  actual SDK stages, countdown and error domain/code; new activator per attempt
  and token-session guards; security-level manual Wi-Fi return confirmation.
- Unsupported EZ is explicitly blocked. Current SSID detection remains disabled
  by Personal Team signing; manual SSID is remembered, password is not persisted.
- User-supplied remote PNG is copied unmodified into an asset. Guide reproduces
  the supplied fast-blink instructions and explicitly does not guess AP remote
  switching instructions absent from the screenshots.
- SDK callback Objective-C selectors verified in generated Breeze-Swift.h for
  final, step, deviceStateError and didPassWIFIToSecurityLevelDeviceWithUUID.
- 11 core tests passed including three deadline/history tests:
  build/pairing-core-tests.log. Three UI tests passed including guide/inputs:
  build/PairingRecoveryUITests.xcresult. A final foreground-refresh guard followed
  those UI binaries; final signed compile passed after that change:
  build/pairing-recovery-final-build.log.
- Settled simulator layout inspected in Screenshots/Pairing-recovery.png. Initial
  capture was taken during launch animation and was replaced after settling.
- Final device installation succeeded (sequence 2916) and process launched:
  build/pairing-recovery-install.json and build/pairing-recovery-launch.json.

VERDICT: PASS

This verifies fixes compile and relevant model/UI behavior. Successful Orient
activation and real AP/security-level SDK events still need the user's fan test.

## AP security handoff binary investigation — 2026-11-03

- Inspected actual shipped arm64 SDK archive using nm/otool. REA server and CLI
  were unavailable; no native analysis provider session was opened.
- Disassembly at 0x6fd4 sets x6=0 in the convenience activation method;
  relocation at 0x6fd8 targets the regInfo overload. Breeze used this path and
  never fetched device security configuration.
- Corrected the sequence to fetch security configuration while online, retain it
  across the manual hotspot switch, and pass it through regInfo. Token-session
  guards and watchdog cover the fetch. Missing/invalid config stops explicitly.
- Signed physical-device build passed: build/security-pairing-fix-build.log.
- Full bounded findings, archive identity and raw static evidence:
  build/reverse-engineering/AP-FINDINGS.md.
- Previous core/UI tests are unchanged and were not rerun for this SDK-only fix.
  Hardware activation remains unverified; static evidence establishes a missing
  documented handoff, not the cause of the user's particular AP failure.

VERDICT: PASS

## Live fan controls, rename and connected widget — 2026-11-03

- User confirmed successful Orient activation after AP security fix.
- Native power Toggle; visible icon enum grids for speed, modes, light and timer;
  numeric Stepper fallback. Original SDK values and validation are preserved.
- Added SDK updateName followed by device refresh; native rename alert.
- Added Connected fan widget, separate from Demo fan. App-group snapshots contain
  display state only, updated on device refresh/reports. Shows first connected fan
  and last-update time; tap opens matching in-app live controls. No background
  SDK command claim.
- Signed build passed: build/live-controls-final-build.log. Four UI tests passed
  including visible choices and rename dialog: build/LiveControlsUITests.xcresult.
  New control tests use a disconnected, named preview fixture; no real fan command
  or server-side rename was executed by automation.
- Installed successfully on iPhone, sequence 2932, then launched:
  build/live-controls-install.json, build/live-controls-launch.json.

VERDICT: PASS

## Compact UI and widget shortcuts — 2026-11-03

- Replaced oversized system-bordered enum capsules with compact rounded tiles;
  speed numbers use minimum 44-point targets and no repeated wind icon.
- Power toggle and confirmed on/off caption moved into compact device header.
  Home header reduced to a single home-name/device-count row.
- Connected widgets use concise state with power and up to six reported speed
  choices. Links open Breeze; commands wait for ongoing refresh, reload home,
  resolve writable SDK controls and use existing validation. They do not run
  in the widget background. No physical fan command was issued during tests.
- Signed build passed: build/compact-controls-build.log. Four UI regression tests
  passed: build/CompactControlsUITests.xcresult. git diff --check passed.
- Installed on physical iPhone (sequence 2940) and launched successfully:
  build/compact-controls-install.json and build/compact-controls-launch.json.

VERDICT: PASS

## Editable widgets, circular selectors and launch crash — 2026-11-03

- Retrieved latest physical Breeze crash (213324) into ignored build/widget-crash.ips.
  Triggered thread asserts in SwiftUI EnvironmentValues.subscript.getter.
  Widget route sheet used ConnectedDeviceView with a required HomeConnection
  environment; explicitly injected connection and store into that sheet.
- New UI regression opens breeze://connected/preview, verifies controls and Done,
  dismisses and verifies underlying controls remain. All five UI tests passed;
  authoritative xcresult summary reports Passed, 5 passed, 0 failed, no warnings.
  Evidence: build/EditableWidgetUITests.xcresult.
- AppIntent widget configuration selects primary and three optional extra fans,
  with lighting/timer visibility options. Large/extra-large use reported enum
  snapshots; missing controls are omitted. User device state/credentials are not
  fabricated. Widget commands still open Breeze and validate against live schema.
- New selectors are 48-point circles with external labels and selected outlines.
- Parallel device/simulator builds collided in CocoaPods shared temporary
  resources-to-copy-Breeze.txt. Device retry after resource phase completion
  passed: build/editable-widget-device-recovery.log. No source workaround used.
- Installed on iPhone successfully, sequence 2948:
  build/editable-widget-install.json. Physical widget-gallery editing/layout
  and real widget command execution still need an on-phone check.

VERDICT: PASS

## Real background widget controls and compact remote — 2026-11-03

- Replaced widget command Links with Button(intent:) for power, speed and exact
  reported enum choices. OpenURL remains only for opening the detail screen.
- Added ControlConnectedFanIntent with background/dynamic supportedModes and
  openAppWhenRun=false. App-only ForegroundContinuable compatibility witness
  selects the shared SDK process. Extracted metadata in BOTH bundles confirmed
  supportedModes=9, ForegroundContinuable protocol, openAppWhenRun=false. The
  compiler flag includes SDK calls only in the app; Keychain/entitlements unchanged.
- Actual on-phone test via iPhone Mirroring: started with Pappu Off on Home Screen,
  tapped Turn on and observed On · Speed 1 with Turn off. No app presentation.
  Tapped Turn off, observed Off / Turn on on the same Home Screen. Initial power
  restored. This verifies real SDK-reported background power, not just compilation.
  Other controls use the same validated dispatch but were not changed physically.
- Removed large detail header and section title; mode/timer/light choices use
  single rows at standard type sizes. Accessibility sizes wrap and may scroll.
- Five UI tests passed, including default-size hittability of Timer 8 and Light
  Level3 without scrolling, plus prior deep-link regression:
  build/BackgroundWidgetUITests.xcresult.
- Size-specific configuration parameter summary compiled after UI tests:
  build/background-widget-sized-build.log. App sizes small/medium show fan
  selection; larger sizes expose extra fan and timer/light settings.
- Real tested build installed (sequence 2956). Final size-settings build is
  delivered via build/background-widget-sized-install.json.

VERDICT: PASS

### Cold widget-title presentation follow-up

The final real-phone title tap exposed a blank sheet on first presentation even
with environment injection. Replaced separate optional ID + isPresented flags
with sheet(item:) on ConnectedFanEntity: one source of route state. Added loading
feedback while home refresh runs. New URL regression also terminates the app
and reopens the widget URL. Signed build passed after the route change:
build/widget-route-final-build.log. This does not alter tested background actions.

Final physical follow-up: installed item-route build successfully (sequence 2972).
Tapped Pappu widget title from Home Screen after installation/cold launch; the
correct Pappu sheet loaded. Visually confirmed live power, speed, mode, timer and
light all visible without scrolling at the phone's current text size. This also
confirms the previous blank-sheet regression is resolved on the user's phone.
The real background power test was restored to Off before this title check.

## Portrait widget, unclipped large panel, Home/Settings and glass sheet

- Confirmed systemExtraLargePortrait exists for iOS 27 in installed WidgetKit
  interface and official Apple documentation. Earlier statements that only iPad
  gets a taller widget were incomplete. Added portrait to supportedFamilies.
- Standard large: removed extra fan footer, removed bordered-button intrinsic
  padding, sized speed/power/enum buttons, anchored content at top. Portrait uses
  roomier rows and optional extra fan shortcuts. Metadata summary matches sizes.
- Added Home and Settings TabView; live fan rows have distinct open/power buttons.
  No Scenes tab. Settings shows actual session/home state and setup guidance.
- Remote is a single native regular glassEffect surface with transparent sheet
  background, dividers, and accessibility scroll fallback.
- Device build passed after fixing NavigationLink initializer:
  build/portrait-glass-fixed-build.log. Six UI tests passed including tabs,
  default-size control hittability, rename, and warm/cold widget URL navigation:
  build/PortraitGlassUITests.xcresult. git diff --check passed.
- Installed on iPhone successfully, sequence 2980: build/portrait-glass-install.json.
- Physical widget-gallery visual check was unavailable: iPhone Mirroring said
  iPhone in Use. Simulator GUI app was unavailable. Tall family declaration and
  compact layout compile; final physical widget rendering still needs checking.
  Simulator display data was seeded with clearly named preview fixtures only.

VERDICT: PASS

## Full-screen matte remote and Home status summary — 2026-11-03

- User likes Home direct actions and tall widget; design focus is device detail.
- Home fan and widget-title routes now use fullScreenCover(item:), retaining
  explicit observable environments. No drawer or full-sheet glass effect.
- Added FanRemoteHeader with reported selected speed and adjacent native power
  toggle. Controls remain schema-driven with accessible circular selectors.
- Added real running-fan/light counts to Home while preserving existing actions.
  No weather is invented and no location/WeatherKit access added.
- Signed build passed: build/matte-remote-build.log. All six UI tests passed:
  build/MatteRemoteUITests.xcresult, including default-size control visibility,
  Home/Settings, rename, and warm/cold full-screen widget routes.
- Installed on physical iPhone successfully, sequence 2988:
  build/matte-remote-install.json. Physical visual review was unavailable
  because iPhone Mirroring reported iPhone in Use.
- Existing tall widgets and working background SDK actions were not changed.

VERDICT: PASS

## Native fan page and compact dashboard — 2026-11-03

- User explicitly rejected modal/drawer motion and Done. Removed fan covers from
  app and Home. ConnectedHomeView owns NavigationStack path; Home appends IDs,
  widget title requests select Home and replace the path. Native back navigation
  and edge swipe are retained. No custom Done or edit button on the fan page.
- Added fan/power hero with native Off/On segment, compact speed/mode/timer
  reported-state tiles, one inline expanded choice group, and an always-present
  light group. Rename moved to options menu. Reduce Motion is respected.
- Presentation labels map timer 0 to Off and hours to h, Revers to Reverse, and
  Level1 to Level 1; SDK raw command values remain unchanged.
- Six UI tests passed before label polish: build/DashboardPageUITests.xcresult.
  Final two relevant UI tests passed after polish:
  build/DashboardFinalControlsUITests.xcresult. These verify inline expansion,
  rename, native back to Breeze, absence of Done, and a cold widget URL route.
- Final signed build passed: build/dashboard-page-final-build.log. Installed
  successfully on the physical iPhone, sequence 3004:
  build/dashboard-page-final-install.json. git diff --check passed.
- Physical visual review unavailable: phone remained in use in Mirroring. SDK
  commands and background widget intents are unchanged; no fan command was
  issued as part of these UI checks.

VERDICT: PASS

Visual follow-up: inspected Screenshots/Fan-dashboard-page.png in the simulator.
The rotating ceiling-fan symbol rotated its stem as well; replaced only that
decorative symbol with fanblades.fill for natural top-down blade rotation. Final
signed compile passed: build/dashboard-hero-final-build.log. Final install
evidence: build/dashboard-hero-final-install.json. Behavioral tests above precede
this symbol-only edit; command and navigation logic are unchanged.

## Home weather and remote spacing, 2026-11-03
- Signed device build PASS: build/weather-home-build.log.
- All 6 affected UI tests PASS: build/WeatherHomeUITests.xcresult. Includes
  controls hittability, rename, pushed widget routes, Home/Settings and pairing.
- Public sample-coordinate weather request succeeded and the real response
  decoded in Swift; night icon assertion passed: build/WeatherResponseCheck.swift.
- Simulator visual review: Screenshots/Spaced-fan-dashboard.png. Taller power
  segment, increased vertical spacing, full-width evenly spaced light choices.
- Physical install and launch succeeded: build/weather-home-install.json
  (sequence 3020), build/weather-home-launch.json.
- Weather uses explicit opt-in approximate foreground location and Open-Meteo
  attribution. Physical location permission/network failure paths not exercised
  on the user's phone; no real fan commands issued during UI verification.
VERDICT: PASS (build, existing UI flows, weather response decoding); physical
weather permission review remains user-observable on first Use my location tap.

## Combined Home/weather card
- Grouped home header and HomeWeatherCard inside one VStack/List row with a
  divider, removing their separate section gap. Status counts remain below.
- Signed build passed: build/combined-home-build.log. git diff --check passed.
- Layout-only grouping; weather/account/command logic unchanged. No extra tests.
