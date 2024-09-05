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
        } else {
            self.body = .text(body.string)
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
            return formattedJsonData.string
        } catch {
            return nil
        }
    }
}
