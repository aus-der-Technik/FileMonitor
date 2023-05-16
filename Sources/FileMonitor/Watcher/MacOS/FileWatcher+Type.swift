//
// aus der Technik, on 16.05.23.
// Based on: https://github.com/eonist/FileWatcher/tree/master
//


import Cocoa
/**
 * Callback signature
 */
extension FileWatcher {
    public typealias CallBack = (_ fileWatcherEvent: FileWatcherEvent) -> Void
}
