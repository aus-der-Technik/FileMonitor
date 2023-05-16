//
// aus der Technik, on 15.05.23.
//

import Foundation

public enum FileChangeEvent {
    case added(file: URL)
    case deleted(file: URL)
    case changed(file: URL)
    // case moved(from: URL, to: URL) // tbd
}

public protocol WatcherDelegate {
    func fileDidChanged(event: FileChangeEvent)
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
