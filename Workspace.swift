//
//  Copyright © Marc Schultz. All rights reserved.
//

import ProjectDescription

let workspace = Workspace(
    name: "Netbob",
    projects: [
        "Demo",
        "Package"
    ],
    fileHeaderTemplate: .string("""
    //
    //  ___COPYRIGHT___
    //
    """)
)
