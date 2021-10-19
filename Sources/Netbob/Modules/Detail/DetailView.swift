//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    @StateObject var state: DetailViewState
    @State var selection = 0

    var body: some View {
        VStack(spacing: 2) {
            Picker("Picker", selection: $selection) {
                Text("General").tag(0)
                Text("Request").tag(1)
                Text("Response").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())

            TabView(selection: $selection) {
                GeneralTab(state: state).tag(0)
                RequestTab(state: state).tag(1)
                ResponseTab(state: state).tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarItems(trailing: ShareButton(state: state))
            .actionSheet(item: $state.actionSheetState) { state in
                ActionSheet(state: state)
            }
            .activitySheet(state: $state.activitySheetState)
        }
    }
}

private struct GeneralTab: View {
    let state: DetailViewState

    var body: some View {
        Form {
            Section(header: Text("General")) {
                KeyValueView(key: "URL", value: state.viewData.requestURL)
                KeyValueView(key: "Method", value: state.viewData.requestMethod)
                KeyValueView(key: "Status", value: state.viewData.responseStatus)
                KeyValueView(key: "Request date", value: state.viewData.requestDate)
                KeyValueView(key: "Response date", value: state.viewData.responseDate)
                KeyValueView(key: "Time interval", value: state.viewData.timeInterval)
                KeyValueView(key: "Timeout", value: state.viewData.requestTimeout)
                KeyValueView(key: "Cache policy", value: state.viewData.requestCachePolicy)
            }
        }
    }
}

private struct RequestTab: View {
    let state: DetailViewState

    var body: some View {
        Form {
            if let requestBody = state.viewData.requestBody {
                NavigationLink("Request Body", destination: BodyView(state: .init(body: requestBody)))
            } else {
                Text("No Request Body").foregroundColor(.secondary)
            }

            Section(header: Text("Header")) {
                ForEach(state.viewData.requestHeaders) { header in
                    KeyValueView(key: header.key, value: header.value)
                }
            }

            Section(header: Text("Query")) {
                ForEach(state.viewData.requestURLQueryItems) { queryItem in
                    KeyValueView(key: queryItem.key, value: queryItem.value)
                }
            }
        }
    }
}

struct ResponseTab: View {
    let state: DetailViewState

    var body: some View {
        Form {
            if let responseBody = state.viewData.responseBody {
                NavigationLink("Response Body", destination: BodyView(state: .init(body: responseBody)))
            } else {
                Text("No Response Body").foregroundColor(.secondary)
            }

            Section(header: Text("Header")) {
                ForEach(state.viewData.responseHeaders) { header in
                    KeyValueView(key: header.key, value: header.value)
                }
            }
        }
    }
}

private struct ShareButton: View {
    let state: DetailViewState

    var body: some View {
        Button {
            state.handleShareAction()
        } label: {
            Text(.init(systemName: "square.and.arrow.up"))
                .fontWeight(.light)
        }
    }
}

// MARK: - Previews

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(state: DetailViewStateMock())
    }
}

private class DetailViewStateMock: DetailViewState {
    init() {
        // swiftlint:disable:next force_unwrapping
        let request = URLRequest(url: URL(string: "https://www.foobar.com")!)
        let connection = HTTPConnection(request: HTTPRequest(from: request))
        super.init(connection: connection)
    }
}
