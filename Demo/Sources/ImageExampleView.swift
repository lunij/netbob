//
//  Copyright © Marc Schultz. All rights reserved.
//

import SwiftUI

struct ImageExampleView: View {
    @StateObject var state = ImageExampleViewState()

    var body: some View {
        VStack {
            state.image
            Button("Show me an image") {
                state.handleAction()
            }
        }
    }
}

class ImageExampleViewState: ObservableObject {
    @Published var image: Image?

    private var dataTask: URLSessionDataTask?

    func handleAction() {
        dataTask?.cancel()

        if let url = URL(string: "https://picsum.photos/400/400/?random") {
            dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
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
    }

    private func handleCompletion(error: String?, data: Data?) {
        if let error = error {
            print(error)
            return
        }

        if let data = data, let uiImage = UIImage(data: data) {
            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}
