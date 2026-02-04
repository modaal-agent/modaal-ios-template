// (c) Copyright Modaal.dev 2026
//
// Based on https://github.com/dscyrescotti/SwiftTheming

/// An abstraction layer to define themes based on theme asset.
public protocol Themeable {
    /// A method that return `Themed` object based on theme.
    /// - Returns: theme object
    func themed() -> Themed
}
