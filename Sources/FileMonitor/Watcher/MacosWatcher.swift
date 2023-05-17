//
// aus der Technik, on 15.05.23.
//

import Foundation
#if os(macOS)

class MacosWatcher: WatcherProtocol {
    var delegate: WatcherDelegate?
    let fileWatcher: FileWatcher
    private var lastFiles: [URL] = []

    required init(directory: URL) throws {

        fileWatcher = FileWatcher([directory.path])
        fileWatcher.queue = DispatchQueue.global()
        lastFiles = try getCurrentFiles(in: directory)

        fileWatcher.callback = { [self] event throws in
            if let url = URL(string: event.path), url.isDirectory == false {
                let currentFiles = try getCurrentFiles(in: directory)

                let removedFiles = getDifferencesInFiles(lhs: lastFiles, rhs: currentFiles)
                let addedFiles = getDifferencesInFiles(lhs: currentFiles, rhs: lastFiles)

                // new file in folder is a change, yet
                if event.fileCreated {
                    self.delegate?.fileDidChanged(event: FileChangeEvent.added(file: url))
                } else if event.fileRemoved {
                    self.delegate?.fileDidChanged(event: FileChangeEvent.deleted(file: url))
                } else {
                    if removedFiles.isEmpty == false {

                    }
                    self.delegate?.fileDidChanged(event: FileChangeEvent.changed(file: url))
                }

                lastFiles = currentFiles
            }
        }
    }

    deinit {
        stop()
    }

    func observe() throws {
        fileWatcher.start()
    }

    func stop() {
        fileWatcher.stop();
    }


}
#endif
