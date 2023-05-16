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

        filewatcher.queue = DispatchQueue.global()

        filewatcher.callback = { event in
            print("Something happened here: " + event.path)
            dump(event)
            if let url = URL(string: event.path) {
                self.delegate?.fileDidChanged(event: FileChangeEvent.changed(file: url))
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
