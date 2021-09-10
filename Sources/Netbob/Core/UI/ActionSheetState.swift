//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct ActionSheetState: Identifiable, Equatable {
    var id: String { title }

    let title: String
    let message: String?
    let actions: [Action]

    enum Action {
        case cancel
        case `default`(text: String, action: () -> Void)
    }

    static func == (lhs: ActionSheetState, rhs: ActionSheetState) -> Bool {
        lhs.id == rhs.id &&
            lhs.message == rhs.message
    }
}

extension ActionSheet {
    init(state: ActionSheetState) {
        self.init(
            title: Text(state.title),
            message: state.message.flatMap(Text.init),
            buttons: state.actions.map { action in
                switch action {
                case .cancel:
                    return .cancel(Text("Cancel"))
                case let .default(text, action):
                    return .default(Text(text), action: action)
                }
            }
        )
    }
}
