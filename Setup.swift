//
//  Copyright © Marc Schultz. All rights reserved.
//

import ProjectDescription

let setup = Setup([
    .homebrew(packages: [
        "swiftformat",
        "xcbeautify"
    ]),
    // make SwiftLint installation work on GitHub Actions as well
    .custom(
        name: "SwiftLint",
        meet: ["brew", "install", "swiftlint"],
        isMet: ["swiftlint"]
    )
])
