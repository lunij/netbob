//
//  Copyright © Marc Schultz. All rights reserved.
//

import ProjectDescription

let name = "Netbob"

let project = Project(
    name: name,
    organizationName: "Marc Schultz",
    packages: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .upToNextMajor(from: "1.9.0"))
    ],
    targets: [
        Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: "com.netbob.framework",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.ipad, .iphone, .mac]),
            infoPlist: .default,
            sources: "../Sources/\(name)/**",
            scripts: [
                .post(script: .swiftLint, name: "Run SwiftLint", basedOnDependencyAnalysis: false)
            ]
        ),
        Target(
            name: "\(name)Tests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.netbob.framework.tests",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.ipad, .iphone, .mac]),
            infoPlist: .default,
            sources: "../Tests/\(name)Tests/**",
            resources: "../Tests/\(name)Tests/Resources/**",
            dependencies: [
                .target(name: name),
                .package(product: "SnapshotTesting")
            ]
        )
    ]
)

extension String {
    static let swiftLint = """
    if which swiftlint >/dev/null; then
        cd ..
        swiftlint
    else
        echo "SwiftLint not installed, run `make setup` first"
    fi
    """
}
