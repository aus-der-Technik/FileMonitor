//
// aus der Technik, on 19.05.23.
//

import Foundation
#if canImport(CInotify)
import CInotify
#endif

#if os(Linux)
public class FileSystemWatcher {
    // inotify_init() initializes a new inotify instance and returns a
    // file descriptor associated with a new inotify event queue.
    private let fileDescriptor: Int32
    private let dispatchQueue: DispatchQueue

    private var watchDescriptor: Int32 = 0
    private var shouldStopWatching: Bool = false

    public init() {
        dispatchQueue = DispatchQueue.global(qos: .background)
        fileDescriptor = inotify_init()
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

        close(fileDescriptor)
    }

    @discardableResult
    public func watch(path: String, for mask: InotifyEventMask, thenInvoke callback: @escaping (InotifyEvent) -> Void) -> Int32 {
        watchDescriptor = inotify_add_watch(fileDescriptor, path, mask.rawValue)

        dispatchQueue.async { [self] in
            let bufferLength: Int = MemoryLayout<inotify_event>.size + Int(NAME_MAX) + 1
            let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferLength)

            while !self.shouldStopWatching {
                var currentIndex: Int = 0
                let readLength = read(fileDescriptor, buffer, bufferLength)

                while currentIndex < readLength {
                    let event = withUnsafePointer(to: &buffer[currentIndex]) {
                        $0.withMemoryRebound(to: inotify_event.self, capacity: 1) {
                            $0.pointee
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
#endif
