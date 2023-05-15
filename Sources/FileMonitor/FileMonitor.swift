
import Foundation

public enum FileMonitorErrors: Error {
    case unsupported_os
    case not_implemented_yet
    case not_a_directory(url: URL)
    case can_not_open(url: URL)
}

public protocol FileDidChangedDelegate {
    func fileDidChanged(file: URL)
}

public struct FileMonitor: WatcherDelegate {

    var watcher: WatcherProtocol
    public var delegate: FileDidChangedDelegate?

    @discardableResult
    public init(directory url: URL, delegate externDelegate: FileDidChangedDelegate? = nil) throws {
        if url.hasDirectoryPath == false {
            throw FileMonitorErrors.not_a_directory(url: url)
        }

        #if os(Linux) || os(FreeBSD)
            watcher = try LinuxWatcher(directory: url)
        #elseif os(macOS)
            watcher = try MacosWatcher(directory: url)
        #elseif os(Windows)
            watcher = try WindowsWatcher(directory: url)
        #else
            throw FileMonitorErrors.unsupported_os()
        #endif

        watcher.delegate = self

        // extern delegate
        if let externDelegate {
            print("Set Ext")
            delegate = externDelegate
        }
        watcher.observe()
    }

    // MARK: - Delegates
    public func fileDidChanged(file changedURL: URL) {
        delegate?.fileDidChanged(file: changedURL)
    }
}
