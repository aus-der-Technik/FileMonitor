//
// aus der Technik, on 15.05.23.
//

import Foundation

struct MacosWatcher: WatcherProtocol {
    var delegate: WatcherDelegate?
    var path: URL?

    init() throws {
        throw FileMonitorErrors.not_implemented_yet
    }

    func start() {

    }

    func stop() {

    }

}
