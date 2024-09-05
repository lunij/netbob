// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Netbob",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "Netbob", targets: ["Netbob"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .upToNextMajor(from: "1.17.4"))
    ],
    targets: [
        .target(
            name: "Netbob",
            dependencies: ["NetbobObjc"]
        ),
        .target(
            name: "NetbobObjc"
        ),
        .testTarget(
            name: "NetbobTests",
            dependencies: [
                "Netbob",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .when(platforms: [.iOS]))
            ],
            exclude: [
                "Modules/Body/__Snapshots__",
                "Modules/Detail/__Snapshots__",
                "Modules/Info/__Snapshots__",
                "Modules/List/__Snapshots__",
                "Modules/Settings/__Snapshots__"
            ],
            resources: [
                .copy("Resources/unsplash.jpg")
            ]
        )
    ]
)
