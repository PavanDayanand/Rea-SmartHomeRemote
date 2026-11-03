import SwiftUI

struct CreateHomeView: View {
    @Environment(HomeConnection.self) private var connection
    @State private var name = "My home"

    var body: some View {
        Form {
            Section {
                Label("Make yourself at home", systemImage: "house")
                    .font(.headline)
                Text("Give your home a name. Then you can add your first fan.")
                    .foregroundStyle(.secondary)
                TextField("Home name", text: $name)
            }
            Section {
                Button("Create home") {
                    connection.run { try await connection.createHome(name: name.trimmingCharacters(in: .whitespacesAndNewlines)) }
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || connection.isBusy)
                if connection.isBusy { ProgressView() }
            }
        }
    }
}
