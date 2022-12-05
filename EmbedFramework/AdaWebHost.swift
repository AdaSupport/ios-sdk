//
//  AdaWebHost.swift
//  AdaSDK
//
//  Created by Aaron Vegh on 2019-05-14.
//  Copyright © 2019 Aaron Vegh. All rights reserved.
//

import Foundation
import WebKit
import SafariServices

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

public class AdaWebHost: NSObject {
    
    public enum AdaWebHostError: Error {
        case WebViewFailedToLoad
        case WebViewTimeout
    }
    
    private var hasError = false
    public var handle = ""
    public var domain = ""
    public var cluster = ""
    public var language = ""
    public var styles = ""
    public var greeting = ""
    public var deviceToken = ""
    public var webViewTimeout = 30.0
    
    
    /// Metafields can be passed in during init; use `setMetaFields()` and `setSensitiveMetafields()`
    /// to send values in at runtime
    private var metafields: [String: Any] = [:]
    private var sensitiveMetafields: [String: Any] = [:]
    
    public var openWebLinksInSafari = false
    public var appScheme = ""
    
    
    public var webViewLoadingErrorCallback: ((Error) -> Void)? = nil
    public var zdChatterAuthCallback: (((@escaping (_ token: String) -> Void)) -> Void)?
    public var eventCallbacks: [String: (_ event: [String: Any]) -> Void]?
    
    ///Set modal navigation bar and status bar to grey by default
    public var navigationBarOpaqueBackground = false
    
    /// Here's where we do our business
    private var webView: WKWebView?
    
    /// Key an eye on the network
    private let reachability: Reachability
    
    /// Keep a reference to the OfflineViewController
    private var offlineViewController: OfflineViewController?
    
    /// Keep track of whether the host is loaded
    private var webHostLoaded = false {
        didSet {
            if webHostLoaded == true {
                self.initializeWebView()
                for command in pendingCommands {
                    self.evalJS(command)
                }
            }
        }
    }
    
    /// Keep track of whether we're showing offline view
    internal var isInOfflineMode = false
    
    /// If commands are sent prior to `embedReady`, store until it can be cleared out
    private var pendingCommands = [String]()
    
    public init(
        handle: String,
        cluster: String = "",
        language: String = "",
        domain: String = "",
        styles: String = "",
        greeting: String = "",
        metafields: [String: Any] = [:],
        sensitiveMetafields: [String:Any] = [:],
        openWebLinksInSafari: Bool = false,
        appScheme: String = "",
        zdChatterAuthCallback: (((@escaping (_ token: String) -> Void)) -> Void)? = nil,
        webViewLoadingErrorCallback: ((Error) -> Void)? = nil,
        eventCallbacks: [String: (_ event: [String: Any]) -> Void]? = nil,
        webViewTimeout: Double = 30.0,
        deviceToken: String = "",
        navigationBarOpaqueBackground: Bool = false
    ) {
        self.handle = handle
        self.cluster = cluster
        self.language = language
        self.styles = styles
        self.domain = domain
        self.greeting = greeting
        self.metafields = metafields
//        we always want to append the sdkType
        self.metafields["sdkType"] = "IOS"
        self.metafields["sdkSupportsDownloadLink"] = true
        self.sensitiveMetafields = sensitiveMetafields
        self.openWebLinksInSafari = openWebLinksInSafari
        self.appScheme = appScheme
        self.zdChatterAuthCallback = zdChatterAuthCallback
        self.webViewLoadingErrorCallback = webViewLoadingErrorCallback
        self.eventCallbacks = eventCallbacks
        self.webViewTimeout = webViewTimeout
        self.hasError = false
        self.deviceToken = deviceToken
        self.navigationBarOpaqueBackground = navigationBarOpaqueBackground
    
        self.reachability = Reachability()!
        super.init()
        
        reachability.whenReachable = { _ in
            self.isInOfflineMode = false
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            guard let strongSelf = self,
                  let webView = strongSelf.webView else { return }
            
            strongSelf.isInOfflineMode = true
            
            if webView.superview != nil {
                strongSelf.offlineViewController = OfflineViewController.create()
                if let offlineVC = strongSelf.offlineViewController {
                    offlineVC.retryBlock = {
                        strongSelf.returnToOnline()
                    }
                    offlineVC.view.translatesAutoresizingMaskIntoConstraints = false
                    webView.addSubview(offlineVC.view)
                    NSLayoutConstraint.activate([
                        offlineVC.view.topAnchor.constraint(equalTo: webView.topAnchor),
                        offlineVC.view.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
                        offlineVC.view.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
                        offlineVC.view.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
                    ])
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdaWebHost.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start reachability notifier.")
        }
        
        setupWebView()
    }
    
    // MARK: - Public Methods
    
    public func setDeviceToken(deviceToken : String) {
        let toRun = "adaEmbed.setDeviceToken(\"\(deviceToken)\");"
        
        self.evalJS(toRun)
    }
    
    /// Push a dictionary of fields to the server
    @available(*, deprecated, message: "This method will be deprecated in the future, please upgrade to MetaFields.Builder.", renamed: "setMetaFields(builder:)")
    public func setMetaFields(_ fields: [String: Any]) {
        guard let json = try? JSONSerialization.data(withJSONObject: fields, options: []),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.setMetaFields(\(jsonString));"
        
        self.evalJS(toRun)
    }

    /// Push a dictionary of fields to the server
    @available(*, deprecated, message: "This method will be deprecated in the future, please upgrade to MetaFields.Builder.", renamed: "setSensitiveMetaFields(builder:)")
    public func setSensitiveMetaFields(_ fields: [String: Any]) {
        guard let json = try? JSONSerialization.data(withJSONObject: fields, options: []),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.setSensitiveMetaFields(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    /// Override method using builder class
    public func setMetaFields(builder: MetaFields.Builder) {
        let metaFields = builder.build().metaFields
        guard let json = try? JSONSerialization.data(withJSONObject: metaFields, options: []),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.setMetaFields(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    public func setSensitiveMetaFields(builder: MetaFields.Builder) {
        let metaFields = builder.build().metaFields
        guard let json = try? JSONSerialization.data(withJSONObject: metaFields, options: []),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.setSensitiveMetaFields(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    /// Re-initialize chat and optionally reset history, language, meta data, etc
    @available(*, deprecated, message: "This method will be deprecated in the future, please upgrade to MetaFields.Builder.", renamed: "reset(metaFields:sensitiveMetaFields:)")
    /// When this method is depreciated, the 4 override reset methods should be replaced
    public func reset(language: String? = nil, greeting: String? = nil, metaFields: [String: Any]? = nil, sensitiveMetaFields: [String: Any]? = nil, resetChatHistory: Bool? = true) {
        
        let data: [String: Any?] = [
            "language": language,
            "greeting": greeting,
            "metaFields": metaFields,
            "sensitiveMetaFields": sensitiveMetaFields,
            "resetChatHistory": resetChatHistory
        ]
        
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.reset(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    public func reset(language: String? = nil, greeting: String? = nil, metaFields: MetaFields.Builder, resetChatHistory: Bool? = true) {
        
        let data: [String: Any?] = [
            "language": language,
            "greeting": greeting,
            "metaFields": metaFields.build().metaFields,
            "sensitiveMetaFields": nil,
            "resetChatHistory": resetChatHistory
        ]
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.reset(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    public func reset(language: String? = nil, greeting: String? = nil, sensitiveMetaFields: MetaFields.Builder, resetChatHistory: Bool? = true) {
        
        let data: [String: Any?] = [
            "language": language,
            "greeting": greeting,
            "metaFields": nil,
            "sensitiveMetaFields": sensitiveMetaFields.build().metaFields,
            "resetChatHistory": resetChatHistory
        ]
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        
        let toRun = "adaEmbed.reset(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    public func reset(language: String? = nil, greeting: String? = nil, metaFields: MetaFields.Builder, sensitiveMetaFields: MetaFields.Builder, resetChatHistory: Bool? = true) {
        
        let data: [String: Any?] = [
            "language": language,
            "greeting": greeting,
            "metaFields": metaFields.build().metaFields,
            "sensitiveMetaFields": sensitiveMetaFields.build().metaFields,
            "resetChatHistory": resetChatHistory
        ]
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.reset(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    public func reset(language: String? = nil, greeting: String? = nil, resetChatHistory: Bool? = true) {
        
        let data: [String: Any?] = [
            "language": language,
            "greeting": greeting,
            "metaFields": nil,
            "sensitiveMetaFields": nil,
            "resetChatHistory": resetChatHistory
        ]
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed),
              let jsonString = String(data: json, encoding: .utf8) else { return }
        let toRun = "adaEmbed.reset(\(jsonString));"
        
        self.evalJS(toRun)
    }
    
    /// Re-initialize chat and optionally reset history, language, meta data, etc
    public func deleteHistory() {
        let toRun = "adaEmbed.deleteHistory();"
        
        self.evalJS(toRun)
    }
    
    public func triggerAnswer(answerId: String) {
        if(webHostLoaded){
            let toRun = "adaEmbed.triggerAnswer(\"\(answerId)\");"
            self.evalJS(toRun)
            return
        }
        
        debugPrint("AdaWebHost.triggerAnswer failed, webView needs to be initialized.")
    }
    
    public func setLanguage(language: String) {
        if(webHostLoaded){
            let toRun = "adaEmbed.setLanguage(\"\(language)\");"
            self.evalJS(toRun)
            return
        }
        
        debugPrint("AdaWebHost.setLanguage failed, webView needs to be initialized.")
    }
    /// Provide a view controller to launch web support from
    /// this will present the chat view modally
    public func launchModalWebSupport(from viewController: UIViewController) {
        guard let webView = webView else { return }
        webView.translatesAutoresizingMaskIntoConstraints = true
        let webNavController = AdaWebHostViewController.createNavController(with: webView)
        webNavController.modalPresentationStyle = .overFullScreen
        if self.navigationBarOpaqueBackground {
            
            webNavController.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.backgroundColor = UIColor(rgb: 0xF3F3F3)
                webNavController.navigationBar.standardAppearance = navBarAppearance
                webNavController.navigationBar.scrollEdgeAppearance = navBarAppearance
            }
        }
        viewController.present(webNavController, animated: true, completion: nil)
    }
    
    /// Provide a navigation controller to push web support onto the stack
    public func launchNavWebSupport(from navController: UINavigationController) {
        guard let webView = webView else { return }
        webView.translatesAutoresizingMaskIntoConstraints = true
        let webController = AdaWebHostViewController.createWebController(with: webView)
        navController.pushViewController(webController, animated: true)
    }
    
    /// Provide a view to inject the web support into
    public func launchInjectingWebSupport(into view: UIView) {
        guard let webView = webView else { return }
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: webView.topAnchor),
            view.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: webView.bottomAnchor)
        ])
    }
}

extension AdaWebHost {
    private func setupWebView() {
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        wkPreferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        let clusterString = cluster.isEmpty ? "" : "\(cluster)."
        let domainString = domain.isEmpty ? "ada" : "\(domain)"
        configuration.userContentController = userContentController
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences = wkPreferences
        webView = WKWebView(frame: .zero, configuration: configuration)
        guard let webView = webView else { return }
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        guard let remoteURL = URL(string: "https://\(handle).\(clusterString)\(domainString).support/mobile-sdk-webview/") else { return }
        let webRequest = URLRequest(url: remoteURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: webViewTimeout)
        webView.load(webRequest)

        userContentController.add(self, name: "embedReady")
        userContentController.add(self, name: "eventCallbackHandler")
        userContentController.add(self, name: "zdChatterAuthCallbackHandler")
        userContentController.add(self, name: "chatFrameTimeoutCallbackHandler")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + webViewTimeout) {
            if(!self.hasError && webView.isLoading){
                webView.stopLoading();
                self.webViewLoadingErrorCallback?(AdaWebHostError.WebViewTimeout)
            }
        }
        
       
        
    }
}

extension AdaWebHost: WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    @available(iOS 14.5, *)
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        
        let localFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)
        
        completionHandler(localFileURL)
        
        DispatchQueue.main.async { [self] in
            // present activity viewer
            let items = [localFileURL]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            findViewController(from: self.webView!)?.present(ac, animated: true)
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            /// Whena  reset method is built - we will need to set this back to false
            self.hasError = true
            self.webViewLoadingErrorCallback?(AdaWebHostError.WebViewFailedToLoad)
    }
    
    // Shared function to handle opening of urls
    public func openUrl(webView: WKWebView, url: URL) -> Swift.Void {
        let httpSchemes = ["http", "https"]
        let urlScheme = url.scheme
        // Handle opening universal links within the host App
        // This requires the appScheme argument to work
        if urlScheme == self.appScheme {
            guard let presentingVC = findViewController(from: webView) else { return }
            presentingVC.dismiss(animated: true) {
                let shared = UIApplication.shared
                if shared.canOpenURL(url) {
                    shared.open(url, options: [:], completionHandler: nil)
                }
            }
        // Only open links in in-app WebView if URL uses HTTP(S) scheme, and the openWebLinksInSafari option is false
        // This is where SUP-43 is likely crashing
        } else if self.openWebLinksInSafari == false && httpSchemes.contains(urlScheme ?? "") {
            let sfVC = SFSafariViewController(url: url)
            guard let presentingVC = findViewController(from: webView) else { return }
            presentingVC.present(sfVC, animated: true, completion: nil)
        } else {
            let shared = UIApplication.shared
            if shared.canOpenURL(url) {
                shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // Used for weblinks and signon (handling window.open js call)
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            openUrl(webView: webView, url: url)
        }
        return nil
    }
    
    // Used for processing all other navigation
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if #available(iOS 14.5, *), navigationAction.shouldPerformDownload{
            decisionHandler(.download)
        } else if navigationAction.request.url!.absoluteString.range(of: "/transcript/") != nil{
            downloadUrl(url: navigationAction.request.url!, fileName: "chat_transcript.txt")
            decisionHandler(.cancel)
        }
        else if navigationAction.navigationType == WKNavigationType.linkActivated {
            if let url = navigationAction.request.url {
                openUrl(webView: webView, url: url)
            }
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    
    // Download the file from the given url and store it locally in the app's temp folder and present the activity viewer.
   private func downloadUrl(url downloadUrl : URL, fileName: String) {
        let localFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        URLSession.shared.dataTask(with: downloadUrl) { data, response, err in
            guard let data = data, err == nil else {
                debugPrint("Error downloading from url=\(downloadUrl.absoluteString): \(err.debugDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                debugPrint("HTTP Status=\(httpResponse.statusCode)")
            }
            // write the downloaded data to a temporary folder
            do {
                try data.write(to: localFileURL, options: .atomic)   // atomic option overwrites it if needed
                DispatchQueue.main.async { [self] in
                    // present activity viewer
                    let items = [localFileURL]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    findViewController(from: self.webView!)?.present(ac, animated: true)
                }
            } catch {
                debugPrint(error)
                return
            }
        }.resume()
    }
    
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
    
        download.delegate = self
    }

}

extension AdaWebHost: WKScriptMessageHandler {
    /// When the webview loads up, it'll pass back a message to here.
    /// Fire our initialize methods when that happens.
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageName = message.name
        if messageName == "embedReady" {
            self.webHostLoaded = true
        } else if let webViewLoadingErrorCallback = self.webViewLoadingErrorCallback, messageName == "chatFrameTimeoutCallbackHandler" {
            webViewLoadingErrorCallback(AdaWebHostError.WebViewTimeout)
        } else if let zdChatterAuthCallback = self.zdChatterAuthCallback, messageName == "zdChatterAuthCallbackHandler" {
            zdChatterAuthCallback() { token in
                self.evalJS("window.zdTokenCallback(\"\(token)\");")
            }
        } else if messageName == "eventCallbackHandler" {
            if let event = message.body as? [String: Any] {
                if let eventName = event["event_name"] as? String {

                    if let specificCallback = self.eventCallbacks?[eventName] {
                        specificCallback(event)
                    }
                }
                
                if let specificCallback = self.eventCallbacks?["*"] {
                    specificCallback(event)
                }
            }
        }
    }
}

extension AdaWebHost {
    private func initializeWebView() {        
        do {
            let metaFieldsData = try JSONSerialization.data(withJSONObject: self.metafields, options: [])
            let metaFieldsJson = String(data: metaFieldsData, encoding: .utf8) ?? "{}"
            
            let sensitiveMetaFieldsData = try JSONSerialization.data(withJSONObject: self.sensitiveMetafields, options: [])
            let sensitiveMetaFieldsJson = String(data: sensitiveMetaFieldsData, encoding: .utf8) ?? "{}"

            evalJS("""
                (function() {
                    window.adaEmbed.start({
                        handle: "\(self.handle)",
                        cluster: "\(self.cluster)",
                        domain: "\(self.domain)",
                        language: "\(self.language)",
                        styles: "\(self.styles)",
                        greeting: "\(self.greeting)",
                        metaFields: \(metaFieldsJson),
                        sensitiveMetaFields: \(sensitiveMetaFieldsJson),
                        parentElement: "parent-element",
                        onAdaEmbedLoaded: () => {
                            adaEmbed.setDeviceToken("\(self.deviceToken)\");
                            adaEmbed.subscribeEvent("ada:chat_frame_timeout", (data, context) => {
                                window.webkit.messageHandlers.chatFrameTimeoutCallbackHandler.postMessage("chatFrameTimeout");
                            });
                        },
                        zdChatterAuthCallback: function(callback) {
                            window.zdTokenCallback = callback;
                            window.webkit.messageHandlers.zdChatterAuthCallbackHandler.postMessage("getToken");
                        },
                        eventCallbacks: {
                            "*": (event) => window.webkit.messageHandlers.eventCallbackHandler.postMessage(event)
                        }
                    });
                })();
            """)
            
        } catch (let error) {
            print("Serialization error: \(error.localizedDescription)")
            return
        }
    }
    
    private func evalJS(_ toRun: String) {
        guard self.webHostLoaded else {
            pendingCommands.append(toRun)
            return
        }
        guard let webView = webView else { return }

        webView.evaluateJavaScript(toRun) { (result, error) in
            if let err = error {
                print(err)
            } else {
                guard let dataValue = result else { return }
                print(dataValue)
            }
        }
    }
    
    private func returnToOnline() {
        guard !isInOfflineMode else { return }
        
        if let offlineVC = self.offlineViewController {
            offlineVC.view.removeFromSuperview()
            self.offlineViewController = nil
        }
        
        // This should reset the webview if client is offline on launch
        if !self.webHostLoaded {
            self.setupWebView()
        }
    }
}

extension AdaWebHost {
    @objc func keyboardWillHide(notification: NSNotification) {
        if #available(iOS 12.0, *) {
            guard let webView = webView else { return }
            
            for view in webView.subviews {
                if view.isKind(of: NSClassFromString("WKScrollView") ?? UIScrollView.self) {
                    guard let scroller = view as? UIScrollView else { return }
                    scroller.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
        }
    }
}

extension AdaWebHost {
    func findViewController(from view: UIView) -> UIViewController? {
        if let nextResponder = view.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = view.next as? UIView {
            return findViewController(from: nextResponder)
        } else {
            return nil
        }
    }
}

public class MetaFields {
    
    internal var metaFields: [String: Any] = [:]
    
    init(metaFields: [String: Any]) {
        self.metaFields = metaFields
    }
    
    public class Builder {
    
        private var metaFields: [String: Any] = [:]
        
        public init() {
            self.metaFields = [:]
        }
        
        public func setField(key: String, value: String) -> MetaFields.Builder {
            self.metaFields[key] = value
            return self
        }
        
        public func setField(key: String, value: Bool) -> MetaFields.Builder {
            self.metaFields[key] = value
            return self
        }
        
        public func setField(key: String, value:Int) -> MetaFields.Builder {
            self.metaFields[key] = value
            return self
        }
        
        public func setField(key: String, value: Float) -> MetaFields.Builder {
            self.metaFields[key] = value
            return self
        }
        
        public func setField(key: String, value: Double) -> MetaFields.Builder {
            self.metaFields[key] = value
            return self
        }
        
        internal func build() -> MetaFields {
            return MetaFields(metaFields: self.metaFields)
        }
    }
}
