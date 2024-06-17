//
// aus der Technik, on 17.05.23.
// https://www.ausdertechnik.de
//

import Foundation
import FileMonitor

/// This example shows how to use `FileMonitor`’s AsyncStream with Swift  Structured Concurrency
@main
public struct FileMonitorAsyncStreamExample {

    /// Main entrypoint
    /// Start FileMonitorExample with an argument to the monitored directory
    /// - Throws: an error when the FileMonitor can't be initialized
    public static func main() async throws {
        let arguments = CommandLine.arguments
        if arguments.count < 2 {
            print("One folder should be provided at least.")
            print("Run \(arguments.first ?? "program") <folder>")
            exit(1)
        }
        guard let folderToWatch = URL(string: arguments[1]) else {
            print("Folder '\(arguments[1])' is not an valid location.")
            exit(1)
        }

        let fileMonitor = FileMonitorAsyncStreamExample()
        try await fileMonitor.run(on: folderToWatch)
    }

    /// Run a file monitor on a given folder
    ///
    /// - Parameter folder: A URL of a directory
    /// - Throws: an error when the FileMonitor can't be initialized
    func run(on folder: URL) async throws {
        print("Monitoring files in \(folder.standardized.path)")

        let monitor = try FileMonitor(directory: folder.standardized)
        try monitor.start()
        // MARK: - AsyncStream
        for await event in monitor.stream {
            print("Stream: \(event.description)")
        }
    }
}
