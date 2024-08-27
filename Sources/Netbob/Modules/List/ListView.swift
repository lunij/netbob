//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @StateObject var state: ListViewStateAbstract

    var body: some View {
        List {
            ForEach(state.connections) { viewData in
                NavigationLink(destination: DetailView(state: .init(connection: viewData.connection))) {
                    ListRow(viewData: viewData)
                }
            }
        }
        .navigationBarItems(trailing: navigationBarButtons)
        .activitySheet(state: $state.activitySheetState)
        .onAppear {
            state.onAppear()
        }
        .onDisappear {
            state.onDisappear()
        }
    }

    var navigationBarButtons: some View {
        HStack(spacing: 20) {
            Button {
                state.handleShareAction()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            Button {
                state.handleSaveAction()
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
            NavigationLink(destination: InfoView(state: InfoViewState())) {
                Image(systemName: "info.circle")
            }
            NavigationLink(destination: SettingsView(state: SettingsViewState())) {
                Image(systemName: "gearshape")
            }
        }
        .font(.system(size: 20, weight: .light))
    }
}

struct ListRow: View {
    let viewData: HTTPConnectionViewData

    var body: some View {
        HStack {
            rectangle
                .frame(width: 10)
                .foregroundColor(viewData.statusColor)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(viewData.requestMethod)
                        .fontWeight(.semibold)
                    Text(viewData.responseStatusCode)
                    Text(viewData.requestTime)
                }
                .font(.system(size: 10, design: .monospaced))

                (
                    Text(viewData.requestScheme)
                        + Text(viewData.requestHost).fontWeight(.semibold)
                        + Text(viewData.requestPath)
                        + Text(viewData.requestQuery).italic()
                )
                .font(.system(size: 10))
                .lineLimit(4)
            }
        }
    }

    @ViewBuilder
    var rectangle: some View {
        if viewData.isFromCurrentSession {
            RoundedRectangle(cornerRadius: 5)
        } else {
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder()
        }
    }
}

extension HTTPConnectionViewData {
    var statusColor: Color {
        switch status {
        case .success:
            return .green
        case .failure:
            return .red
        case .timeout:
            return .orange
        }
    }
}

// MARK: - Previews

// swiftlint:disable force_unwrapping

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(state: ListViewStateMock())
    }
}

private class ListViewStateMock: ListViewStateAbstract {
    override init() {
        super.init()
        connections = [
            .fake(status: .success),
            .fake(status: .timeout),
            .fake(status: .failure),
            .fake(status: .success, isFromCurrentSession: false),
            .fake(status: .timeout, isFromCurrentSession: false),
            .fake(status: .failure, isFromCurrentSession: false)
        ]
    }
}

private extension HTTPConnectionViewData {
    static func fake(
        status: HTTPConnectionViewData.Status,
        isFromCurrentSession: Bool = true
    ) -> Self {
        .init(
            requestTime: "fakeTime",
            requestMethod: "GET",
            requestScheme: "https://",
            requestHost: "foobar.com",
            requestPath: "/a/b/c",
            requestQuery: "?d=1,e=2,f=3",
            responseStatusCode: "200",
            status: status,
            isFromCurrentSession: isFromCurrentSession,
            connection: .init(request: HTTPRequest(from: URLRequest(url: URL(string: "https://foobar.com")!)))
        )
    }
}

// swiftlint:enable force_unwrapping
