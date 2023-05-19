//
// aus der Technik, on 17.05.23.
// https://www.ausdertechnik.de
//

import Foundation

public enum FileChangeEvent {
    case added(file: URL)
    case deleted(file: URL)
    case changed(file: URL)

    // Display friendly description of the event
    public var description: String {
        get {
            switch self {
            case .added(file: let file):
                return "Added:    \(file.path)"
            case .deleted(file: let file):
                return "Deleted:  \(file.path)"
            case .changed(file: let file):
                return "Modified: \(file.path)"
            }
        }
    }
}
