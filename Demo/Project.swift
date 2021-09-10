//
//  Copyright © Marc Schultz. All rights reserved.
//

import ProjectDescription

let project = Project(
    name: "NetbobDemo",
    packages: [
        .package(path: "..")
    ],
    targets: [
        Target(
            name: "NetbobDemo",
            platform: .iOS,
            product: .app,
            bundleId: "com.netbob.demo",
            infoPlist: .file(path: "Info.plist"),
            sources: "Sources/**",
            dependencies: [
                .package(product: "Netbob")
            ]
        )
    ]
)
