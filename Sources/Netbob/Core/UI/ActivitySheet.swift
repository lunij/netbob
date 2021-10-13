//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct ActivitySheet: UIViewControllerRepresentable {
    var activityItem: ActivityItemProtocol
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(
            activityItems: [context.coordinator],
            applicationActivities: applicationActivities
        )
        controller.modalPresentationStyle = .automatic
        return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(activityItem)
    }

    class Coordinator: NSObject, UIActivityItemSource {
        private let activityItem: ActivityItemProtocol

        init(_ activityItem: ActivityItemProtocol) {
            self.activityItem = activityItem
            super.init()
        }

        func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
            activityItem.placeholder
        }

        func activityViewController(_: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            activityItem.item(for: activityType)
        }

        func activityViewController(_: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            activityItem.subject(for: activityType)
        }
    }
}
