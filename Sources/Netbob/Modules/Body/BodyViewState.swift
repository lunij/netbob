//
//  Copyright © Marc Schultz. All rights reserved.
//

import UIKit

class BodyViewState {
    let body: Body

    init(body: Data) {
        if let uiImage = UIImage(data: body) {
            self.body = .image(uiImage)
        } else if let string = body.prettyJson {
            self.body = .json(string)
        } else if let string = String(data: body, encoding: .utf8) {
            self.body = .text(string)
        } else {
            self.body = .data(body)
        }
    }

    func handleCopyAction() {
        switch body {
        case let .json(string), let .text(string):
            UIPasteboard.general.string = string
        default:
            break
        }
    }

    enum Body: Equatable {
        case data(Data)
        case image(UIImage)
        case json(String)
        case text(String)
    }
}

extension Data {
    var prettyJson: String? {
        do {
            let rawJsonData = try JSONSerialization.jsonObject(with: self, options: [])
            let formattedJsonData = try JSONSerialization.data(withJSONObject: rawJsonData, options: [.prettyPrinted])
            return String(data: formattedJsonData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
