//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    @StateObject var state: InfoViewState

    var body: some View {
        Form {
            Section(header: Text("IP Addresses")) {
                ForEach(state.interfaceViewData) { interface in
                    KeyValueView(key: interface.name, value: interface.ipAddresses)
                }
            }

            Section(header: Text("Request")) {
                KeyValueView(key: "Total requests", value: state.summaryViewData.requestCount)
                KeyValueView(key: "Successful requests", value: state.summaryViewData.successfulRequests)
                KeyValueView(key: "Failed requests", value: state.summaryViewData.failedRequests)
                KeyValueView(key: "Total request size", value: state.summaryViewData.totalRequestBodySize)
                KeyValueView(key: "Average request size", value: state.summaryViewData.averageRequestBodySize)
            }

            Section(header: Text("Response")) {
                KeyValueView(key: "Total response size", value: state.summaryViewData.totalResponseBodySize)
                KeyValueView(key: "Average response size", value: state.summaryViewData.averageResponseBodySize)
                KeyValueView(key: "Average response time", value: state.summaryViewData.averageResponseTime)
                KeyValueView(key: "Fastest response time", value: state.summaryViewData.fastestResponseTime)
                KeyValueView(key: "Slowest response time", value: state.summaryViewData.slowestResponseTime)
            }
        }
        .onAppear {
            state.onAppear()
        }
        .onDisappear {
            state.onDisappear()
        }
    }
}

// MARK: - Previews

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(state: InfoViewState())
    }
}
