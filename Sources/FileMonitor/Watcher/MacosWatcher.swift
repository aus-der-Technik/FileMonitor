//
// aus der Technik, on 15.05.23.
//

import Foundation

class MacosWatcher: WatcherProtocol {
    var delegate: WatcherDelegate?
    let dispatchSource: DispatchSourceFileSystemObject

    var dirFD : Int32 = -1 {
        didSet {
            if oldValue != -1 {
                close(oldValue)
            }
        }
    }
    public var isRunning: Bool { dirFD != -1 }

    required init(directory: URL) throws {
        dirFD = open(directory.path, O_EVTONLY)
        print("+++", dirFD)
        if dirFD < 0 {
            throw FileMonitorErrors.can_not_open(url: directory)
        }
        dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: dirFD,
                eventMask: .all,
                queue: .main
        )
        dispatchSource.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.handleEvent()
        }

        dispatchSource.setCancelHandler { [weak self] in
            self?.dirFD = -1
        }

    }

    deinit {
        stop()
    }

    func observe() {
        print("A")
        dispatchSource.resume()
        print("B")
    }

    func stop() {
        dispatchSource.setEventHandler(handler: nil)
        dispatchSource.cancel()
    }

    func handleEvent()  {
        print("+++ EVENT +++")
        delegate?.fileDidChanged(file: URL(filePath: "foo"))

        //let currentFiles = getCurrentFiles()
        //let newFiles = listNewFiles(lastFiles: lastFiles, currentFiles: currentFiles)
        //let deletedFiles = listDeletedFiles(lastFiles: lastFiles, currentFiles: currentFiles)

        //let changes = DirectoryChangeSet(newFiles: newFiles, deletedFiles: deletedFiles)
        //delegate?.directoryWatcher(self, changed: changes)

        //lastFiles = currentFiles
    }
}
