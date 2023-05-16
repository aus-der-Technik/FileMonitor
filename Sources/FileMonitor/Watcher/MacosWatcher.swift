//
// aus der Technik, on 15.05.23.
//

import Foundation

#if os(macOS)
class MacosWatcher: WatcherProtocol {
    var delegate: WatcherDelegate?
    let dispatchSource: DispatchSourceFileSystemObject
    let queue = DispatchQueue.init(label: "filechanges", qos: .background)
    let observingDirectory: URL

    var directoryFileHandle : Int32 = -1 {
        didSet {
            if oldValue != -1 {
                close(oldValue)
            }
        }
    }
    var isRunning: Bool { directoryFileHandle != -1 }
    private var lastFiles: [URL] = []

    required init(directory: URL) throws {
        directoryFileHandle = open(directory.path, O_EVTONLY)

        if directoryFileHandle < 0 {
            throw FileMonitorErrors.can_not_open(url: directory)
        }

        observingDirectory = directory

        dispatchSource = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: directoryFileHandle,
                eventMask: .all,
                queue: queue
        )
        dispatchSource.setEventHandler { [weak self] in
            guard let self = self else { return }
            try? self.handleEvent()
        }
        dispatchSource.setCancelHandler { [weak self] in
            self?.directoryFileHandle = -1
        }

    }

    deinit {
        stop()
    }

    func observe() throws {
        lastFiles = try getCurrentFiles(in: observingDirectory)
        dispatchSource.resume()
    }

    func stop() {
        dispatchSource.setEventHandler(handler: nil)
        dispatchSource.cancel()
        lastFiles.removeAll()
    }

    func handleEvent() throws {
        let currentFiles = try getCurrentFiles(in: observingDirectory)
        let filesDeleted = listChanges(lhs: lastFiles, rhs: currentFiles)
        let filesAdded = listChanges(lhs: currentFiles, rhs: lastFiles)
        print("filesAdded \(filesAdded)")
        print("filesDeleted \(filesDeleted)")

        filesDeleted.forEach { delegate?.fileDidRemoved(file: $0) }
        filesAdded.forEach { delegate?.fileDidAdded(file: $0) }
        if filesDeleted.isEmpty && filesAdded.isEmpty {
            delegate?.fileDidChanged(directory: observingDirectory)
        }

        lastFiles = currentFiles
    }

    private func listChanges(lhs: [URL], rhs: [URL]) -> Set<URL> {
        Set(lhs).subtracting(rhs)
    }

}
#endif
