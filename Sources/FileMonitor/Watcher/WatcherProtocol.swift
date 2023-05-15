//
// aus der Technik, on 15.05.23.
//

import Foundation

protocol WatcherDelegate {
    func fileDidChanged(file: URL)
}

protocol WatcherProtocol {
    var delegate: WatcherDelegate? { set get }
    var path: URL? { set get }
    init() throws
    func start()
    func stop()
}
