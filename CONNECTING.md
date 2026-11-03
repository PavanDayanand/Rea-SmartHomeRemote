# Direct pairing in Breeze

The requested experience is now **Breeze owns onboarding and control**:

1. Sign into a Breeze account.
2. Create a home and rooms.
3. Tap Add fan, choose an Orient Aeroslim and its pairing mode.
4. Allow location access with Precise Location to fill in the current Wi-Fi name,
   or type it manually. Enter its password, confirm the network supports 2.4 GHz,
   and follow the fan's reset instructions.
5. Pair through the hardware platform's SDK and receive its device identifier.
6. Read the actual device data-point schema, then control power, speed, modes,
   lighting and supported device-side schedules from native SwiftUI screens.

This supersedes the earlier proposed Smart Life account-linking flow. The
user-provided SDK is now integrated, with native setup, login, home, AP/EZ pairing,
and schema-driven controls in source. Compilation does not prove activation of
this particular Orient firmware; a real single-fan test is still required.

The user requested personal use with no vendor AI. Only the basic device SDK is
requested in `Podfile`. No AI/voice/LLM pods appear in the resolved dependency
list. The SDK's cloud login and pairing-token requirements still apply.

### Apple Wi-Fi detection capability

The user's current free Personal Team cannot provision Access Wi-Fi Information;
Xcode rejected it on 2026-11-03. The installed build therefore uses manual Wi-Fi
entry and does not request location permission. The detection helper is ready
for a team enrolled in the Apple Developer Program. With that team selected,
run `python3 scripts/generate_project.py --enable-wifi-info`, then `pod install`
and build the workspace. This enables both the capability and the detection UI.
It reads only the current network name, not the password or its frequency band.

## Required before a real pairing build

The Tuya SDK is a candidate because the user reports this fan works in Smart Life.
That is evidence of ecosystem compatibility, not proof that this exact Orient
product can be activated under a newly registered SDK app. Verify the latter on
one fan only after SDK registration and integration are ready.

Tuya requires an SDK app registration with these matching values:

- iOS Bundle ID: `com.pavand.breeze`
- iOS AppKey and AppSecret for that SDK app/version
- Its generated security component/image, as required by the selected SDK version
- The matching SDK package/Podfile from the platform

These are not the end-user password for the Orient app. They cannot be derived
from screenshots. Registration, terms, and any paid selection belong to the user;
do not accept agreements or purchase a subscription automatically. Confirm the
current development-edition limits in the portal rather than assuming it is a
perpetual free service.

The updated iPhone setup screen accepts the iOS AppKey and AppSecret and stores
them in that phone's Keychain. Editing a local file is optional and not required.
Keep the SDK credentials and generated security files outside source control.
Never paste them into chat, include them in logs, or use Orient's own app secrets.

## Implementation boundaries

- Keep the app's SwiftUI views small and beginner-readable.
- Put platform SDK calls in one small connection/controller area.
- Do not create a screen that falsely reports a fan has paired.
- Do not ask the user to reset a working fan until actual pairing is ready to test.
- A fan already owned by another app/account may need to be unbound/re-paired;
  determine this using the chosen SDK and device behavior before giving steps.
- Revalidate Siri/widget background and shared-credential behavior with the SDK.
- Use confirmed device reports for live state, not optimistic demo state.

## Official references checked on 2026-11-03

- SDK integration and matching credentials:
  https://developer.tuya.com/en/docs/app-development/integrate-sdk?id=Ka5d52ewngdoi
- Official Swift sample:
  https://github.com/tuya/tuya-home-ios-sdk-sample-swift
- Getting the platform-generated SDK package:
  https://support.tuya.com/en/help/_detail/K8sdy2meotl4v

The sample includes login, homes, EZ/AP Wi-Fi pairing and device control. Those
are the reusable vendor components; Breeze will supply its own native interface.

## Pairing recovery and progress

The installed Personal Team build supports manual AP pairing. EZ requires
Apple’s multicast entitlement and is blocked rather than allowed to time out.
The remote guide uses the supplied Orient remote image and the exact four EZ
steps shown in the user’s screenshots. Those screenshots do not establish the
remote sequence for switching to slow-blinking AP mode; Breeze does not guess it.

Pairing has a 25-second token deadline, a 10-minute manual hotspot deadline, and
a 125-second activation watchdog around the SDK’s 120-second timeout. Foreground
return rechecks deadlines and skips cloud home refresh while pairing. Only SDK
callbacks advance the fan-found/registered/complete stages. Failure keeps the
last stage and supplied SDK error domain/code visible. Security-level AP devices
can request return to home Wi-Fi; Breeze asks the user to confirm that switch
before calling continueConfigSecurityLevelDevice. Without the Wi-Fi entitlement,
Breeze cannot independently verify which network the user joined.

Only the home SSID is remembered in app preferences. The Wi-Fi password and
pairing token stay in memory and are cleared after handoff or cancellation.
Live activation with this Orient firmware still needs a real fan test.
