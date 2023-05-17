import CInotify
import Dispatch
import Foundation

// Heavily inspired by https://github.com/felix91gr/FileSystemWatcher/blob/master/Sources/fswatcher.swift

// See https://www.man7.org/linux/man-pages/man7/inotify.7.html
public struct InotifyEvent {
  // Watch descriptor
  public var watchDescriptor: Int
  // Mask describing the event
  public var mask: UInt32
  // Used on rename events
  public var cookie: UInt32

  // Size of the name field
  public var length: UInt32
  // Normally the file name
  public var name: String
}

extension InotifyEvent: Hashable {
    public static func ==(lhs: InotifyEvent, rhs: InotifyEvent) -> Bool {
        lhs.watchDescriptor == rhs.watchDescriptor
        && lhs.name == rhs.name
        && lhs.mask == rhs.mask
        && lhs.cookie == rhs.cookie
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(watchDescriptor)
        hasher.combine(name)
        hasher.combine(mask)
        hasher.combine(cookie)
    }
}

public enum InotifyEventMask: UInt32 {
  case inAccess             = 0x00000001 // File was accessed
  case inModify             = 0x00000002 // File was modified
  case inAttrib             = 0x00000004 // Metadata changed

  case inCloseWrite         = 0x00000008 // Closed after opened for wriitng
  case inCloseNoWrite       = 0x00000010 // Closed after opening for reading
  case inClose              = 0x00000018 // Closed (independent of mode)

  case inOpen               = 0x00000020 // File opened
  case inMovedFrom          = 0x00000040 // Old file before move
  case inMovedTo            = 0x00000080 // New file after move
  case inMove               = 0x000000C0 // On any move event

  case inCreate             = 0x00000100 // New file created
  case inDelete             = 0x00000200 // File deleted
  case inDeleteSelf         = 0x00000400 // File itself was deleted
  case inMoveSelf           = 0x00000800 // File itself was moved

  case inUnmount            = 0x00002000 // FS was unmounted
  case inQueueOverflow      = 0x00004000 // Queue overflowed
  case inIgnored            = 0x00008000 // Watch for file removed

  case inOnlyDir            = 0x01000000 // Set to only watch if is a dir
  case inDontFollow         = 0x02000000 // Dont watch if is symlink
  case inExcludeUnlink      = 0x04000000 // Ignore events for children if not applicable

  case inMaskAdd            = 0x20000000 // Dont overwrite watch masks

  case inIsDir              = 0x40000000 // File is a directory
  case inOneShot            = 0x80000000 // Only watch for changes once

  case inAllEvents          = 0x00000FFF // Meta value to watch all events
}

public class FileSystemWatcher {
    private let fileDescriptor: Int
    private let dispatchQueue: DispatchQueue

    private var watchDescriptor: Int = 0
    private var shouldStopWatching: Bool = false

    public init() {
        //dispatchQueue = DispatchQueue(label: "inotify.queue", qos: .background, attributes: [.initiallyInactive, .concurrent])
        dispatchQueue = DispatchQueue.global(qos: .background)
        fileDescriptor = Int(inotify_init())
        if fileDescriptor < 0 {
            fatalError("Failed to initialize inotify")
        }
    }

    deinit {
        stop()
    }

    public func start() {
        shouldStopWatching = false
        dispatchQueue.activate()
    }

    public func stop() {
        shouldStopWatching = true
        dispatchQueue.suspend()

        // ToDo: Does this imply that stop() deinits this watcher (and thus needs to be recreated?)
        if watchDescriptor > 0 {
            inotify_rm_watch(Int32(fileDescriptor), Int32(watchDescriptor))
        }
        close(Int32(fileDescriptor))
    }

    @discardableResult public func watch(path: String, for mask: InotifyEventMask, thenInvoke callback: @escaping (InotifyEvent) -> Void) -> Int {
        watchDescriptor = Int(inotify_add_watch(Int32(fileDescriptor), path, mask.rawValue))

        dispatchQueue.async {
            let bufferLength = Int(MemoryLayout<inotify_event>.size) + Int(NAME_MAX) + 1
            let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferLength)

            while !self.shouldStopWatching {
                var currentIndex: Int = 0
                let readLength = read(Int32(self.fileDescriptor), buffer, bufferLength)

                while currentIndex < readLength {
                    let event = withUnsafePointer(to: &buffer[currentIndex]) {
                        return $0.withMemoryRebound(to: inotify_event.self, capacity: 1) {
                            return $0.pointee
                        }
                    }

                    if event.len > 0 {
                        let inotifyEvent = InotifyEvent(
                            watchDescriptor: Int(event.wd),
                            mask: event.mask,
                            cookie: event.cookie,
                            length: event.len,
                            name: String(cString: buffer + currentIndex + MemoryLayout<inotify_event>.size)
                        )

                        self.dispatchQueue.async() { 
                            callback(inotifyEvent)
                        }
                    }

                    currentIndex += MemoryLayout<inotify_event>.stride + Int(event.len)
                }
            }
        }

        return watchDescriptor
    }
}
