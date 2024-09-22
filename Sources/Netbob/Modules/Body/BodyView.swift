//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct BodyView: View {
    let state: BodyViewState

    var body: some View {
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                copyButton
            }
        }
    }

    @ViewBuilder
    var content: some View {
        switch state.body {
        case let .data(data):
            Text("Data \(data.count)")
        case let .image(uiImage):
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        case let .json(string), let .text(string):
            TextEditor(text: .constant(string))
                .font(.system(size: 10, weight: .regular, design: .monospaced))
        }
    }

    var copyButton: some View {
        Button(action: state.handleCopyAction) {
            Text(.init(systemName: "doc.on.doc"))
                .fontWeight(.light)
        }
    }
}

// MARK: - Previews

struct BodyView_Previews: PreviewProvider {
    static var imageData: Data {
        UIImage(systemName: "house")!.pngData()! // swiftlint:disable:this force_unwrapping
    }

    static var textData: Data {
        "fakeText".data
    }

    static var previews: some View {
        BodyView(state: BodyViewState(body: textData))
            .previewModifier()
        BodyView(state: BodyViewState(body: imageData))
            .previewModifier()
    }
}

private extension View {
    func previewModifier() -> some View {
        previewLayout(.fixed(width: 300, height: 300))
    }
}
