//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var state: SettingsViewStateAbstract

    private let maxItemsText = "MaxItems: "

    var body: some View {
        VStack {
            Form {
                Section {
                    Toggle("Enabled", isOn: $state.isEnabled)
                }

                Section {
                    ForEach(state.contentTypes.indices) { index in
                        Toggle(state.contentTypes[index].name, isOn: $state.contentTypes[index].isEnabled)
                            .toggleStyle(CheckmarkToggleStyle())
                    }
                }

                Section(header: Text("Blacklist")) {
                    ForEach(state.blacklistedHosts, id: \.self) { host in
                        Text(host)
                    }
                }

                Section {
                    Button("Clear session") {
                        state.handleClearAction()
                    }
                    .foregroundColor(.red)
                }

                Section {
                    VStack {
                        state.maxItems != nil ? Text("List limit: \(state.maxItems ?? 0)") : Text("List limit: no limit")

                        Slider(
                            value: maxItemsBinding,
                            in: 100 ... 1100,
                            step: 100,
                            label: { Text("Max list items") },
                            minimumValueLabel: { Text("\(100)") },
                            maximumValueLabel: { Text("no limit") },
                            onEditingChanged: { _ in
                                Netbob.shared.maxListItems = state.maxItems
                            }
                        )
                    }
                }
            }

            Text(Netbob.version)
        }
        .navigationTitle("Settings")
        .actionSheet(item: $state.actionSheetState) { state in
            ActionSheet(state: state)
        }
    }

    var maxItemsBinding: Binding<Double> {
        .init {
            Double(state.maxItems ?? 1100)
        } set: { newValue in
            state.maxItems = newValue == 1100 ? nil : Int(newValue)
        }
    }
}

struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            Button {
                configuration.isOn.toggle()
            } label: {
                if configuration.isOn {
                    Image(systemName: "checkmark")
                } else {
                    EmptyView()
                }
            }
            .foregroundColor(.accentColor)
        }
    }
}
