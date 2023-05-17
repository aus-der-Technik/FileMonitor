
import Foundation

public enum FileMonitorErrors: Error {
    case unsupported_os
    case not_implemented_yet
    case not_a_directory(url: URL)
    case can_not_open(url: URL)
}

public typealias FileDidChangedDelegate = WatcherDelegate

public struct FileMonitor: WatcherDelegate {

    var watcher: WatcherProtocol
    public var delegate: FileDidChangedDelegate? {
        didSet {
            // further improvement:
            // bind watcher.delegate direct to delegate to get rid of call-tree
        }
    }

    @discardableResult
    public init(directory url: URL, delegate externDelegate: FileDidChangedDelegate? = nil) throws {
        if url.hasDirectoryPath == false {
            throw FileMonitorErrors.not_a_directory(url: url)
        }

        // extern delegate
        if let externDelegate {
            delegate = externDelegate
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
    }

    public func start() throws {
        try watcher.observe()
    }

    // MARK: - WatcherDelegate

    public func fileDidChanged(event: FileChangeEvent) {
        // TODO: Implement logger
        switch event {
            case let .added(file):
                print("FILE added", file)
            case let .deleted(file):
                print("FILE deleted", file)
            case let .changed(file):
                print("FILE changed", file)
        }
        // pass to external delegeate 
        delegate?.fileDidChanged(event: event)
    }

}
