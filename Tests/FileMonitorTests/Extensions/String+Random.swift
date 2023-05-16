//
// aus der Technik, on 16.05.23.
//


import Foundation

/// Extends a `String` with functions to generate a random literal
///
extension String {

    /// Character set to building a random string from
    ///
    struct RandomCharacterSet {
        typealias Value = String
        var value: Value = ""

        static var aZ09: RandomCharacterSet {
            get {
                RandomCharacterSet(value: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
            }
        }
        static var codeVerifier: RandomCharacterSet {
            get {
                RandomCharacterSet(value: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
            }
        }

        static func custom(_ characterSet: String) -> RandomCharacterSet {
            RandomCharacterSet(value: characterSet)
        }
    }

    /// returns a random string of variable length
    ///
    /// - Parameter
    ///     - length: The length of the generated string
    ///     - of: A set of characters to build the string from, default:
    ///         `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`
    /// - Returns: The generated string
    ///
    static func random(length: Int, of letterSet: RandomCharacterSet = RandomCharacterSet.aZ09) -> String {
        let letters = letterSet.value
        return String((0..<length).compactMap { _ in
            letters.randomElement()
        })
    }

}
