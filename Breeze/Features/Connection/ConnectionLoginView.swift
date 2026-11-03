import SwiftUI

struct ConnectionLoginView: View {
    @Environment(HomeConnection.self) private var connection
    @State private var email = ""
    @State private var password = ""
    @State private var countryCode = "91"
    @State private var code = ""
    @State private var creatingAccount = true

    var body: some View {
        Form {
            Section {
                Label("Your own home, in Breeze", systemImage: "fan.ceiling.fill")
                    .font(.headline)
                Text("Create a Breeze device account to pair your fans here. It is separate from your Orient account and uses Tuya’s device service. No AI is involved.")
                    .foregroundStyle(.secondary)
            }
            Section {
                Picker("Account", selection: $creatingAccount) {
                    Text("Create account").tag(true)
                    Text("Sign in").tag(false)
                }
                .pickerStyle(.segmented)
                TextField("Country calling code", text: $countryCode)
                    .keyboardType(.numberPad)
                TextField("Email", text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(creatingAccount ? .newPassword : .password)
                if creatingAccount {
                    TextField("Email verification code", text: $code)
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                    Button("Send verification email") {
                        connection.run { try await connection.sendCode(email: email, countryCode: countryCode) }
                    }
                    .disabled(email.isEmpty || countryCode.isEmpty || connection.isBusy)
                }
            }
            if let message = connection.message {
                Section { Text(message).font(.footnote) }
            }
            Section {
                Button(creatingAccount ? "Create Breeze account" : "Sign in") {
                    connection.run {
                        if creatingAccount {
                            try await connection.register(email: email, password: password, code: code, countryCode: countryCode)
                        } else {
                            try await connection.login(email: email, password: password, countryCode: countryCode)
                        }
                        password = ""
                        code = ""
                    }
                }
                .disabled(email.isEmpty || password.isEmpty || countryCode.isEmpty || (creatingAccount && code.isEmpty) || connection.isBusy)
                if connection.isBusy { ProgressView("Connecting…") }
            }
        }
    }
}
