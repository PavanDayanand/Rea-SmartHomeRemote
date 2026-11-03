import SwiftUI

struct FanDetailView: View {
    let fanID: String
    @Environment(FanStore.self) private var store

    var body: some View {
        if let fan = store.fan(id: fanID) {
            Form {
                Section {
                    FanHeaderView(fan: fan)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }

                Section {
                    LabeledContent("Fan", value: fan.summary)
                    Button(fan.isOn ? "Turn fan off" : "Turn fan on", systemImage: "power") {
                        store.perform { try store.setPower(id: fan.id, isOn: !fan.isOn) }
                    }
                    .accessibilityIdentifier("detail.power")
                }

                Section {
                    SpeedControlView(fan: fan)
                } header: {
                    Text("Wind speed")
                } footer: {
                    Text("Choosing a speed turns the demo fan on. Six levels are shown for this preview.")
                }

                Section("Make it comfortable") {
                    NavigationLink {
                        ModePickerView(fanID: fan.id)
                    } label: {
                        LabeledContent {
                            Text(fan.mode.rawValue).foregroundStyle(.secondary)
                        } label: {
                            Label("Mode", systemImage: fan.mode.symbol)
                        }
                    }
                    NavigationLink {
                        LightPickerView(fanID: fan.id)
                    } label: {
                        LabeledContent {
                            Text(fan.lightDescription).foregroundStyle(.secondary)
                        } label: {
                            Label("Light", systemImage: "lightbulb")
                        }
                    }
                    NavigationLink {
                        CountdownView(fanID: fan.id)
                    } label: {
                        LabeledContent {
                            if let date = fan.turnsOffAt {
                                Text(date, style: .time).foregroundStyle(.secondary)
                            } else {
                                Text("Off").foregroundStyle(.secondary)
                            }
                        } label: {
                            Label("Sleep timer", systemImage: "timer")
                        }
                    }
                }

                Section {
                    Label("Demo controls only", systemImage: "info.circle")
                    Text("Changes are saved in Breeze and its widgets. No commands are sent to your Orient fan.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(fan.name)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ContentUnavailableView("Fan not found", systemImage: "fan.ceiling")
        }
    }
}
