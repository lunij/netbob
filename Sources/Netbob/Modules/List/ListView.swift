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
    }

    var navigationBarButtons: some View {
        HStack(spacing: 20) {
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
            RoundedRectangle(cornerRadius: 5)
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
        Group {
            ListView(state: ListViewState())

            ListRow(viewData: .init(
                requestTime: "fakeTime",
                requestMethod: "GET",
                requestScheme: "https",
                requestHost: "foobar.com",
                requestPath: "/a/b/c",
                requestQuery: "d=1,e=2,f=3",
                responseStatusCode: "200",
                status: .success,
                connection: .init(request: HTTPRequest(from: URLRequest(url: URL(string: "https://foobar.com")!))))
            )
            .previewLayout(.fixed(width: 300, height: 50))
        }
    }
}
