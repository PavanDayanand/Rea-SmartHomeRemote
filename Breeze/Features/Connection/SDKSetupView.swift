import SwiftUI

/// This is a one-time setup for your personal build, not a fan pairing password.
struct SDKSetupView: View {
    @Environment(HomeConnection.self) private var connection
    @State private var appKey = ""
    @State private var appSecret = ""

    var body: some View {
        Form {
            Section {
                Label("Connect Breeze", systemImage: "wifi")
                    .font(.title2.bold())
                Text("One quick setup, then you can add your fans directly in this app.")
                    .foregroundStyle(.secondary)
            }
            Section("On your Mac") {
                Text("In the Tuya Developer Platform, open Breeze → Get Key. Find the iOS AppKey and AppSecret.")
                Text("Copy each value and paste it into the matching field below. These are for Breeze, not your Wi-Fi network.")
                    .foregroundStyle(.secondary)
            }
            Section {
                SecureField("iOS AppKey", text: $appKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .privacySensitive()
                SecureField("iOS AppSecret", text: $appSecret)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .privacySensitive()
            } header: {
                Text("Your iOS app settings")
            } footer: {
                Text("Saved in this iPhone’s Keychain. Do not paste the values into chat.")
            }
            Section {
                Button("Save and continue") {
                    do {
                        try connection.saveSDKSettings(appKey: appKey, appSecret: appSecret)
                        appKey = ""
                        appSecret = ""
                    } catch {
                        connection.errorMessage = error.localizedDescription
                    }
                }
                .disabled(appKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
