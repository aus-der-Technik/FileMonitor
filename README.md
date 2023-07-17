# FileMonitor

Watch for file changes in a directory with a unified API on Linux and macOS.

## Overvie
Detecting file changes is an OS-specific task, and the implementation differs on each major platform. While Linux uses 
sys/inotify, macOS lacks this functionality and provide `FSEventStream`. Even though there are many examples available 
for specific platforms, the interfaces still differ.

To address this, we have created the FileMonitor package. We have included code from various sources, which were not 
actively maintained, to provide a reliable and consistent interface for detecting file changes in a directory across 
all supported platforms.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faus-der-Technik%2FFileMonitor%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/aus-der-Technik/FileMonitor)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faus-der-Technik%2FFileMonitor%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/aus-der-Technik/FileMonitor)



## Features

FileMonitor focuses on monitoring file changes within a given directory. It offers the following features:

- Detection of file creations
- Detection of file modifications
- Detection of file deletions

All events are propagated through a delegate function using a switchable enum type.

## Installation
FileMonitor can be easily installed using the Swift Package Manager. Simply add the following line to your dependencies
in your Package.swift file:

```swift
.package(url: "https://github.com/aus-der-Technik/FileMonitor.git", from: "1.0.0")
```

Don't forget to add the product "FileMonitor" as a dependency for your target:
```swift
.product(name: "FileMonitor", package: "FileMonitor"),
```

## Usage
To use FileMonitor, follow this example:

```swift
import FileMonitor
import Foundation

struct FileMonitorExample: FileDidChangeDelegate {
    init() throws {
        let dir = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Downloads")
        let monitor = try FileMonitor(directory: dir, delegate: self )
        try monitor.start()
    }
    
    public func fileDidChanged(event: FileChange) {
        switch event {
        case .added(let file):
            print("New file \(file.path)")
        default:
            print("\(event)")
        }
    }
}
```

You can find a command-line application example in Sources/FileMonitorExample.

## Compatibility
FileMonitor is compatible with Swift 5.7+ on macOS and Linux platforms.

[x] MacOS
[x] Linux
[] Windows

## Contributing
Thank you for considering contributing to the FileMonitor Swift package! Contributions are welcome and greatly 
appreciated.

If you encounter any bugs or have ideas for new features, please open an issue on the GitHub repository. When opening 
an issue, please provide as much detail as possible, including steps to reproduce the issue or a clear description of 
the new feature.

Pull Requests (PRs) are also welcome! If you have implemented a bug fix or added a new feature, follow these steps to 
submit a PR:

1. Fork the repository and create your branch from main.
2. Make your changes, ensuring that you follow the code style and conventions used in the package.
3. Write tests to cover your changes, if applicable.
4. Ensure that all existing tests pass.
5. Update the documentation and README.md if necessary.
6. Commit your changes with a descriptive commit message.
7.Push your branch to your forked repository.
8. Open a PR on the main repository, providing a detailed description of your changes.

9. Please note that all contributions will be reviewed by the maintainers, who may provide feedback or request modifications before merging the changes.


## Credits 
This package builds on the shoulders of giants. We took existing code and cleaned it up, providing a unified interface 
that looks the same across all target machines.

This software is heavily inspired by

- https://github.com/felix91gr/FileSystemWatcher/blob/master/Sources/fswatcher.swift
- https://github.com/eonist/FileWatcher/tree/master

# LICENSE
The FileMonitor Swift package is released under the MIT License.
