//
// aus der Technik, on 16.05.23.
// https://www.ausdertechnik.de
//
// Based on: https://github.com/eonist/FileWatcher/tree/master
//

import Foundation

#if os(macOS)
/**
 * - Parameters:
 *    - id: is an id number that the os uses to differentiate between events.
 *    - path: is the path the change took place. its formatted like so: Users/John/Desktop/test/text.txt
 *    - flag: pertains to the file event type.
 * ## Examples:
 * let url = NSURL(fileURLWithPath: event.path)//<--formats paths to: file:///Users/John/Desktop/test/text.txt
 * Swift.print("fileWatcherEvent.fileChange: " + "\(event.fileChange)")
 * Swift.print("fileWatcherEvent.fileModified: " + "\(event.fileModified)")
 * Swift.print("\t eventId: \(event.id) - eventFlags:  \(event.flags) - eventPath:  \(event.path)")
 */
public class FileWatcherEvent {
    public var id: FSEventStreamEventId
    public var path: String
    public var flags: FSEventStreamEventFlags

    init(_ eventId: FSEventStreamEventId, _ eventPath: String, _ eventFlags: FSEventStreamEventFlags) {
        id = eventId
        path = eventPath
        flags = eventFlags
    }
}

/**
 * The following code is to differentiate between the FSEvent flag types (aka file event types)
 * - Remark: Be aware that .DS_STORE changes frequently when other files change
 */
extension FileWatcherEvent {
    // General
    var fileChange: Bool { (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsFile)) != 0 }
    var dirChange: Bool { (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsDir)) != 0 }
    // CRUD
    var created: Bool { (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated)) != 0 }
    var removed: Bool { (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved)) != 0 }
    var renamed: Bool { (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed)) != 0 }
    var modified: Bool { (flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified)) != 0 }
}

/**
 * Convenience
 */
extension FileWatcherEvent {
    // File
    public var fileCreated: Bool { fileChange && created }
    public var fileRemoved: Bool { fileChange && removed }
    public var fileRenamed: Bool { fileChange && renamed }
    public var fileModified: Bool { fileChange && modified }
    // Directory
    public var dirCreated: Bool { dirChange && created }
    public var dirRemoved: Bool { dirChange && removed }
    public var dirRenamed: Bool { dirChange && renamed }
    public var dirModified: Bool { dirChange && modified }
}

/**
 * Simplifies debugging
 * ## Examples:
 * Swift.print(event.description) // Outputs: The file /Users/John/Desktop/test/text.txt was modified
 */
extension FileWatcherEvent {
    public var description: String {
        var result = "The \(fileChange ? "file":"directory") \(path) was"
        if removed { result += " removed" }
        else if created { result += " created" }
        else if renamed { result += " renamed" }
        else if modified { result += " modified" }
        return result
    }
}
#endif
