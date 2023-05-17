//
// aus der Technik, on 15.05.23.
//

import Foundation
#if os(macOS)

class MacosWatcher: WatcherProtocol {
    var delegate: WatcherDelegate?
    let fileWatcher: FileWatcher

    required init(directory: URL) throws {
        fileWatcher = FileWatcher([directory.path])
        fileWatcher.queue = DispatchQueue.global()

        fileWatcher.callback = { event in
            if let url = URL(string: event.path), url.isDirectory == false {
                print("DELEGATE: ", url.path)
                // new file in folder is a change, yet
                if event.fileCreated {
                    self.delegate?.fileDidChanged(event: FileChangeEvent.added(file: url))
                } else if event.fileRemoved {
                    self.delegate?.fileDidChanged(event: FileChangeEvent.deleted(file: url))
                } else {
                    self.delegate?.fileDidChanged(event: FileChangeEvent.changed(file: url))
                }
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
