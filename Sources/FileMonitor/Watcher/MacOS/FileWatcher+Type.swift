//
// aus der Technik, on 16.05.23.
// Based on: https://github.com/eonist/FileWatcher/tree/master
//

#if os(macOS)
import Cocoa
/**
 * Callback signature
 */
extension FileWatcher {
    public typealias CallBack = (_ fileWatcherEvent: FileWatcherEvent) -> Void
}
#endif
