//
// aus der Technik, on 15.05.23.
//

import Foundation
#if os(macOS)

class MacosWatcher: WatcherProtocol {
    var delegate: WatcherDelegate?
    let filewatcher: FileWatcher

    required init(directory: URL) throws {
        filewatcher = FileWatcher([directory.path])

        //filewatcher.queue = DispatchQueue.global()

        filewatcher.callback = { event in
            print("Something happened here: " + event.path)

            if let url = URL(string: event.path) {
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
        filewatcher.start()
    }

    func stop() {
        filewatcher.stop();
    }


}
#endif
