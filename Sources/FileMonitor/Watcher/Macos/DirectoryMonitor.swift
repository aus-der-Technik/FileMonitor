//
// aus der Technik, on 15.05.23.
// STOLEN FROM: https://github.com/blackbeltlabs/SwiftDirectoryWatcher

import Foundation

public struct DirectoryChangeSet {
    public var newFiles: Set<URL>
    public var deletedFiles: Set<URL>
}

public protocol DirectoryWatcherDelegate {
    func directoryWatcher(_ watcher: DirectoryWatcher, changed: DirectoryChangeSet)
}

public extension DirectoryWatcherDelegate {
    func directoryWatcher(_ watcher: DirectoryWatcher, error: Error) {}
}

public class DirectoryWatcher {
    public var delegate: DirectoryWatcherDelegate?
    public var url: URL
    private var lastFiles: [URL] = []

    var path: String { return url.path }

    var dirFD : Int32 = -1 {
        didSet {
            if oldValue != -1 {
                close(oldValue)
            }
        }
    }

    public var isRunning: Bool {
        return dirFD != -1
    }

    private var dispatchSource : DispatchSourceFileSystemObject?

    public init(url: URL) {
        self.url = url
    }

    deinit {
        stop()
    }

    @discardableResult public func start() -> Bool {
        if isRunning {
            return false
        }

        lastFiles = getCurrentFiles()

        dirFD = open(path, O_EVTONLY)
        if dirFD < 0 {
            return false
        }

        let dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: dirFD,
                eventMask: .write,
                queue: .main)

        dispatchSource.setEventHandler { [weak self] in
            guard let self = self else { return }

            self.handleChangeEvent()
        }

        dispatchSource.setCancelHandler { [weak self] in
            self?.dirFD = -1
        }

        self.dispatchSource = dispatchSource

        dispatchSource.resume()

        return true
    }

    public func stop() {
        guard let dispatchSource = dispatchSource else {
            return
        }

        dispatchSource.setEventHandler(handler: nil)

        dispatchSource.cancel()
        self.dispatchSource = nil
    }

    func getCurrentFiles() -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: [.creationDateKey, .typeIdentifierKey],
                    options: [.skipsHiddenFiles]
            )
        } catch {
            delegate?.directoryWatcher(self, error: error)
            return []
        }
    }

    func handleChangeEvent()  {
        let currentFiles = getCurrentFiles()
        let newFiles = listNewFiles(lastFiles: lastFiles, currentFiles: currentFiles)
        let deletedFiles = listDeletedFiles(lastFiles: lastFiles, currentFiles: currentFiles)

        let changes = DirectoryChangeSet(newFiles: newFiles, deletedFiles: deletedFiles)
        delegate?.directoryWatcher(self, changed: changes)

        lastFiles = currentFiles
    }

    func listNewFiles(lastFiles: [URL], currentFiles: [URL]) -> Set<URL> {
        createDiff(left: currentFiles, right: lastFiles)
    }

    func listDeletedFiles(lastFiles: [URL], currentFiles: [URL]) -> Set<URL> {
        createDiff(left: lastFiles, right: currentFiles)
    }

    func createDiff(left: [URL], right: [URL]) -> Set<URL> {
        Set(left).subtracting(right)
    }
}