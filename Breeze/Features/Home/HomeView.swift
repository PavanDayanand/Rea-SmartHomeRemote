import SwiftUI

struct HomeView: View {
    @Environment(FanStore.self) private var store
    @State private var showingAbout = false
    @State private var path: [String] = []

    var body: some View {
        @Bindable var store = store

        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    introduction
                    demoNotice

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your fans")
                            .font(.title2.bold())

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 290))], spacing: 16) {
                            ForEach(store.fans) { fan in
                                FanCardView(fan: fan)
                            }
                        }
                    }

                    Label("Made for the little things. Like a perfect breeze.", systemImage: "leaf")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Breeze")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("About Breeze", systemImage: "info.circle") {
                        showingAbout = true
                    }
                }
            }
            .sheet(isPresented: $showingAbout) { AboutView() }
            .navigationDestination(for: String.self) { fanID in
                FanDetailView(fanID: fanID)
            }
            .onOpenURL { url in
                guard url.scheme == "breeze", url.host == "fan",
                      store.fan(id: url.lastPathComponent) != nil else { return }
                path = [url.lastPathComponent]
            }
            .alert("Couldn’t save that change", isPresented: .init(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "Please try again.")
            }
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your home, just right.")
                .font(.title3.weight(.medium))
            Text("A little light. A little breeze.")
                .foregroundStyle(.secondary)
        }
    }

    private var demoNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Demo home").font(.subheadline.bold())
                Text("Try the controls. Your real fans aren’t connected yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.teal.opacity(0.08), in: .rect(cornerRadius: 18))
    }
}

#Preview {
    HomeView().environment(FanStore())
}
