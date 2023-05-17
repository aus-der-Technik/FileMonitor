//
// aus der Technik, on 17.05.23.
//

import Foundation

extension URL {

    var isDirectory: Bool {
        var boolFalse: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &boolFalse) && boolFalse.boolValue {
            return true
        }
        return false
    }
}
