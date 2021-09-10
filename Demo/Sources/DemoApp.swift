//
//  Copyright © Marc Schultz. All rights reserved.
//

import Netbob
import SwiftUI

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Examples")) {
                    NavigationLink("Image example", destination: ImageExampleView())
                    NavigationLink("Text example", destination: TextExampleView())
                }

                NavigationLink("Netbob", destination: Netbob.shared.createView)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
