//
// aus der Technik, on 15.05.23.
//

import Foundation
#if os(Linux) || os(FreeBSD)
import CInotify
#endif

struct LinuxWatcher: WatcherProtocol {
    var fsWatcher: FileSystemWatcher
    var delegate: WatcherDelegate?
    var path: URL

    init(directory: URL) {
        fsWatcher = FileSystemWatcher()
        path = directory
    }

    func observe() throws {
        fsWatcher.watch(path: self.path.path, for: InotifyEventMask.inAllEvents) { fsEvent in
            print("New Event!")
            dump(fsEvent)

            guard let url = URL(string: fsEvent.name) else {
                return;
            }

            // ToDo: Type
            let event = FileChangeEvent.changed(file: url)
            
            self.delegate?.fileDidChanged(event: event)
        }
        fsWatcher.start()
    }

    func stop() {
        fsWatcher.stop()
    }
}
