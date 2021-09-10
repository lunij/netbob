//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var state: SettingsViewStateAbstract

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
            }

            Text(Netbob.version)
        }
        .navigationTitle("Settings")
        .actionSheet(item: $state.actionSheetState) { state in
            ActionSheet(state: state)
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
