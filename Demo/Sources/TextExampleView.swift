//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct TextExampleView: View {
    @StateObject var state = TextExampleViewState()

    var body: some View {
        VStack {
            Text(state.string)
            Button("Show me a joke") {
                state.handleAction()
            }
        }
    }
}

class TextExampleViewState: NSObject, ObservableObject {
    @Published var string = ""

    private(set) var session: URLSession?
    private(set) var dataTask: URLSessionDataTask?

    func handleAction() {
        dataTask?.cancel()

        if session == nil {
            session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        }

        guard let url = URL(string: "https://api.chucknorris.io/jokes/random") else { return }

        dataTask = session?.dataTask(with: .init(url: url)) { data, response, error in
            if let error = error {
                self.handleCompletion(error: error.localizedDescription, data: data)
            } else {
                guard let data = data else {
                    self.handleCompletion(error: "Invalid data", data: nil)
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    self.handleCompletion(error: "Invalid response", data: data)
                    return
                }

                guard response.statusCode >= 200, response.statusCode < 300 else {
                    self.handleCompletion(error: "Invalid response code", data: data)
                    return
                }

                self.handleCompletion(error: error?.localizedDescription, data: data)
            }
        }

        dataTask?.resume()
    }

    private func handleCompletion(error: String?, data: Data?) {
        DispatchQueue.main.async {
            if let error = error {
                print(error)
                return
            }

            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                    if let message = dict?["value"] as? String {
                        self.string = message
                    }
                } catch {}
            }
        }
    }
}

extension TextExampleViewState: URLSessionDelegate {
    func urlSession(_: URLSession, didReceive _: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
    }
}
