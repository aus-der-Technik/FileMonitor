//
// aus der Technik, on 15.05.23.
//

import Foundation

struct MacosWatcher: WatcherProtocol {
    var delegate: WatcherDelegate?
    var path: URL?

    let fileHandle: FileHandle
    let source: DispatchSourceFileSystemObject

    init(directory: URL) throws {
        fileHandle = try FileHandle(forReadingFrom: directory)
        source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fileHandle.fileDescriptor,
                eventMask: .all,
                queue: DispatchQueue.main
        )
        source.setEventHandler { [self] in
            let event = self.source.data
            process(event: event)
        }

        source.setCancelHandler { [self] in
            try? fileHandle.close()
        }
    }

    func observe() {


    }

    func stop() {

    }

    private func process(event: DispatchSource.FileSystemEvent){
        dump(event)
    }
}
