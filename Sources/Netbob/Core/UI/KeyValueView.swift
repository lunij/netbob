//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct KeyValueView: View {
    let key: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(key)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
            Text(value)
                .font(.system(size: 12))
        }
        .contextMenu {
            Button("Copy") {
                UIPasteboard.general.string = key + "\n" + value
            }
        }
    }
}
