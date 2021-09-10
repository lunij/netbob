//
//  Copyright © Marc Schultz. All rights reserved.
//

import Foundation

class AuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    typealias AuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

    let handler: AuthenticationChallengeHandler

    init(handler: @escaping AuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }

    func use(_ credential: URLCredential, for _: URLAuthenticationChallenge) {
        handler(.useCredential, credential)
    }

    func continueWithoutCredential(for _: URLAuthenticationChallenge) {
        handler(.useCredential, nil)
    }

    func cancel(_: URLAuthenticationChallenge) {
        handler(.cancelAuthenticationChallenge, nil)
    }

    func performDefaultHandling(for _: URLAuthenticationChallenge) {
        handler(.performDefaultHandling, nil)
    }

    func rejectProtectionSpaceAndContinue(with _: URLAuthenticationChallenge) {
        handler(.rejectProtectionSpace, nil)
    }
}
