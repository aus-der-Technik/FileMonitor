//
// aus der Technik, on 15.05.23.
//

import Foundation

protocol WatcherDelegate {
    func fileDidAdded(file: URL)
    func fileDidRemoved(file: URL)
    func fileDidChanged(directory: URL)
}

protocol WatcherProtocol {
    var delegate: WatcherDelegate? { set get }

    init(directory: URL) throws
    func observe() throws
    func stop()
}

extension WatcherProtocol {
    func getCurrentFiles(in directory: URL) throws -> [URL] {
         try FileManager.default.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: [.creationDateKey, .typeIdentifierKey],
                    options: [.skipsHiddenFiles]
            )

    }
}
