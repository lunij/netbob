//
//  Copyright © Marc Schultz. All rights reserved.
//

import ProjectDescription

let project = Project(
    name: "NetbobDemo",
    organizationName: "Marc Schultz",
    packages: [
        .local(path: ".")
    ],
    targets: [
        .target(
            name: "NetbobDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.netbob.demo",
            infoPlist: "Demo/Info.plist",
            sources: "Demo/Sources/**",
            scripts: [
                .post(
                    script: .swiftLint,
                    name: "Run SwiftLint",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .package(product: "Netbob")
            ]
        )
    ]
)

extension String {
    static let swiftLint = """
    $HOME/.local/bin/mise x -- swiftlint
    """
}
