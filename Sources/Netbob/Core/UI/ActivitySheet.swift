//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct ActivitySheet: UIViewControllerRepresentable {
    var state: ActivitySheetState

    func makeUIViewController(context _: Context) -> some UIViewController {
        let controller = UIActivityViewController(
            activityItems: state.items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = state.excludedActivityTypes
        return controller
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

struct ActivitySheetState: Identifiable {
    let id = UUID()
    let items: [Any]
    private(set) var excludedActivityTypes: [UIActivity.ActivityType] = []
}

extension View {
    func activitySheet(state: Binding<ActivitySheetState?>) -> some View {
        sheet(item: state) { state in
            ActivitySheet(state: state)
        }
    }
}

// MARK: - Previews

struct ActivitySheet_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .activitySheet(state: .constant(ActivitySheetState(items: ["text"])))
    }
}
