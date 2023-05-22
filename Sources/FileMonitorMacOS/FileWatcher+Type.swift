//
// aus der Technik, on 16.05.23.
// https://www.ausdertechnik.de
//
// Based on: https://github.com/eonist/FileWatcher/tree/master
//

#if canImport(Cocoa)
import Cocoa
#endif

#if os(macOS)
/**
 * Callback signature
 */
extension FileWatcher {
    public typealias CallBack = (_ fileWatcherEvent: FileWatcherEvent) throws -> Void
}
#endif
