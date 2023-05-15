//
// aus der Technik, on 15.05.23.
//

import Foundation

struct WindowsWatcher: WatcherProtocol {

    var delegate: WatcherDelegate?
    var path: URL?

    init(directory: URL) throws {
        throw FileMonitorErrors.not_implemented_yet
    }

    func observe() throws {

    }

    func stop() {

    }

}
