//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

protocol ActivityItemProtocol {
    var placeholder: Any { get }
    func item(for activityType: UIActivity.ActivityType?) -> Any?
    func subject(for activityType: UIActivity.ActivityType?) -> String
}

extension ActivityItemProtocol {
    func subject(for _: UIActivity.ActivityType?) -> String {
        ""
    }
}

struct ActivitySheet: UIViewControllerRepresentable {
    var applicationActivities: [UIActivity]?

    var activityItem: ActivityItemProtocol?

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(activityItems: [context.coordinator], applicationActivities: applicationActivities)
        controller.modalPresentationStyle = .automatic
        return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(activityItem)
    }

    class Coordinator: NSObject, UIActivityItemSource {
        public typealias UIActivityType = UIActivity.ActivityType

        private let activityItem: ActivityItemProtocol?

        init(_ activityItem: ActivityItemProtocol?) {
            self.activityItem = activityItem
            super.init()
        }

        func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
            activityItem?.placeholder ?? ""
        }

        func activityViewController(_: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
            activityItem?.item(for: activityType) ?? ""
        }

        func activityViewController(_: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
            activityItem?.subject(for: activityType) ?? ""
        }
    }
}
