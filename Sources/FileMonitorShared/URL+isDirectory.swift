//
// aus der Technik, on 17.05.23.
// https://www.ausdertechnik.de
//

import Foundation

public extension URL {

    // Is the URL a directory?
    var isDirectory: Bool {
        var boolFalse: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &boolFalse) && boolFalse.boolValue
    }
}
