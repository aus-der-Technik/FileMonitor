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
            // self.delegate?.fileDidChanged(directory: directory)
            //self.delegate?.fileDidChanged(file: .added(file: event.path))
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
