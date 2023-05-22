//
// aus der Technik, on 16.05.23.
// https://www.ausdertechnik.de
//
// Heavily inspired by https://github.com/felix91gr/FileSystemWatcher/blob/master/Sources/fswatcher.swift
// See https://www.man7.org/linux/man-pages/man7/inotify.7.html

import Foundation
import Dispatch

/// A single Inotify event
public struct InotifyEvent {
  // Watch descriptor
  public let watchDescriptor: Int

  // Mask describing the event
  public let mask: UInt32

  // Used on rename events
  public let cookie: UInt32

  // Size of the name field
  public let length: UInt32

  // Normally the file name
  public let name: String
}

/// Equability and hashability of an Inotify Event
extension InotifyEvent: Equatable, Hashable {
    public static func == (lhs: InotifyEvent, rhs: InotifyEvent) -> Bool {
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

/// Type of the event (from sys/inotify.h)
public enum InotifyEventMask: UInt32 {
  case inAccess             = 0x00000001 // File was accessed
  case inModify             = 0x00000002 // File was modified
  case inAttrib             = 0x00000004 // Metadata changed

  case inCloseWrite         = 0x00000008 // Closed after opened for writing
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

