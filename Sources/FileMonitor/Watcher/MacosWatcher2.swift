//
// aus der Technik, on 15.05.23.
//

import Foundation
import FileWatcher

class MacosWatcher2: WatcherProtocol {
    var delegate: WatcherDelegate?
    let filewatcher: FileWatcher

    required init(directory: URL) throws {
        filewatcher.queue = DispatchQueue.global()

        filewatcher = FileWatcher([directory.path])
        filewatcher.callback = { event in
            print("Something happened here: " + event.path)
            dump(event)
            // self.delegate?.fileDidChanged(directory: directory)
            self.delegate?.fileDidChanged(file: .added(file: event.path))
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
