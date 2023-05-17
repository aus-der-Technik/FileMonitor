import Foundation
import FileMonitor

@main
public struct FileMonitorExample: FileDidChangedDelegate {

    /// Main entrypoint
    /// Start FileMonitorExample with an argument to the monitored directory
    /// - Throws: an error when the FileMonitor can't be initialized
    public static func main() throws {
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

        let fileMonitor = FileMonitorExample()
        try fileMonitor.run(on: folderToWatch);
    }

    /// Run a file monitor on a given folder
    ///
    /// - Parameter folder: A URL of a directory
    /// - Throws: an error when the FileMonitor can't be initialized
    func run(on folder: URL) throws {
        print("Monitoring files in \(folder.standardized.path)")

        let monitor = try FileMonitor(directory: folder.standardized, delegate: self )
        try monitor.start();

        RunLoop.main.run()
    }

    // MARK: - Delegate FileDidChanged

    /// Called when a file change event occurs
    ///
    /// - Parameter event: A FileChange event
    public func fileDidChanged(event: FileChangeEvent) {
        print("\(event)")
    }
}
