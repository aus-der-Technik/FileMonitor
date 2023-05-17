// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileMonitor",
    platforms: [
      .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
                name: "FileMonitor",
                targets: ["FileMonitor"]),
        .executable(
                name: "FileMonitorExample",
                targets: ["FileMonitorExample"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FileMonitor",
            dependencies: [
                .target(name: "CInotify", condition: .when(platforms: [.linux]))
            ]
        ),
        .systemLibrary(name: "CInotify",
            path: "Sources/Inotify"
        ),
        .executableTarget(
                name: "FileMonitorExample",
                dependencies: ["FileMonitor"]),
        .testTarget(
            name: "FileMonitorTests",
            dependencies: ["FileMonitor"]),
    ]
)
