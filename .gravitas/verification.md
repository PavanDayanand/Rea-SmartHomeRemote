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
