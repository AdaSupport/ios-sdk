import Foundation

public protocol AdaWebHostDelegate: AnyObject {
    /// Use this function to handle urls inside the app.
    /// Should return false if app will handle the url.
    func adaWebHost(_ host: AdaWebHost, shouldOpenUrl url: URL) -> Bool
}

public extension AdaWebHostDelegate {
    func adaWebHost(_ host: AdaWebHost, shouldOpenUrl url: URL) -> Bool {
        true
    }
}
