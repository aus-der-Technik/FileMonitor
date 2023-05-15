//
// aus der Technik, on 15.05.23.
//

import Foundation

protocol WatcherDelegate {
    func fileDidChanged(file: URL)
}

protocol WatcherProtocol {
    var delegate: WatcherDelegate? { set get }

    init(directory: URL) throws
    func observe()
    func stop()
}
