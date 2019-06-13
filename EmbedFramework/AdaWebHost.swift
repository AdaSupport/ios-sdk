//
//  AdaWebHost.swift
//  AdaSDK
//
//  Created by Aaron Vegh on 2019-05-14.
//  Copyright © 2019 Aaron Vegh. All rights reserved.
//

import Foundation
import WebKit

public class AdaWebHost: NSObject {
    
    public var handle = ""
    public var cluster = ""
    public var language = ""
    public var styles = ""
    public var greeting = ""
    
    /// Metafields can be passed in during init; use `setMetaFields()`
    /// to send values in at runtime
    private var metafields: [String: String]?
    
    /// Here's where we do our business
    private var webView: WKWebView?
    
    /// Key an eye on the network
    private let reachability: Reachability
    
    /// Keep a reference to the OfflineViewController
    private var offlineViewController: OfflineViewController?
    
    /// Keep track of whether the host is loaded
    private var webHostLoaded = false
    
    public init(handle: String, cluster: String, language: String, styles: String, greeting: String, metafields: [String: String]?) {
        self.handle = handle
        self.cluster = cluster
        self.language = language
        self.styles = styles
        self.greeting = greeting
        self.metafields = metafields
        self.reachability = Reachability()!
        super.init()
        
        reachability.whenReachable = { _ in
            if let offlineVC = self.offlineViewController {
                offlineVC.view.removeFromSuperview()
                self.offlineViewController = nil
            }
            
            // This should reset the webview if client is offline on launch
            if !self.webHostLoaded {
                self.setupWebView()
            }
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            guard let strongSelf = self,
                  let webView = strongSelf.webView else { return }
            if webView.superview != nil {
                strongSelf.offlineViewController = OfflineViewController.create()
                if let offlineVC = strongSelf.offlineViewController {
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
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start reachability notifier.")
        }
        
        setupWebView()
    }
    
    // MARK: - Public Methods
    
    /// Push a dictionary of fields to the server
    public func setMetaFields(_ fields: [String: Any]) {
        let serializedData = try! JSONSerialization.data(withJSONObject: fields, options: [])
        let encodedData = serializedData.base64EncodedString()
        let toRun = "setMetaFields('\(encodedData)');"
        
        self.evalJS(toRun)
    }
    
    /// Provide a view controller to launch web support from
    /// this will present the chat view modally
    public func launchModalWebSupport(from viewController: UIViewController) {
        guard let webView = webView else { return }
        let webNavController = AdaWebHostViewController.createNavController(with: webView)
        viewController.present(webNavController, animated: true, completion: nil)
    }
    
    /// Provide a navigation controller to push web support onto the stack
    public func launchNavWebSupport(from navController: UINavigationController) {
        guard let webView = webView else { return }
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
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: configuration)
        guard let webView = webView else { return }
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        
        guard let remoteURL = URL(string: "https://\(handle).ada-dev.support/mobile-sdk-webview/") else { return }
        let webRequest = URLRequest(url: remoteURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(webRequest)
        userContentController.add(self, name: "embedReady")
    }
}

extension AdaWebHost: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error loading")
    }
}

extension AdaWebHost: WKScriptMessageHandler {
    /// When the webview loads up, it'll pass back a message to here.
    /// Fire our initialize methods when that happens.
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("PM: \(message.name), \(message.body) ")
        if message.name == "embedReady" {
            self.webHostLoaded = true
            self.initializeWebView()
        }
    }
}

extension AdaWebHost {
    private func initializeWebView() {
        do {
            let dictionaryData = [
                "handle": self.handle,
                "domain": "ada-dev",
                "cluster": self.cluster,
                "language": self.language,
                "styles": self.styles,
                "greeting": self.greeting
                ] as [String : Any]
            let serializedData = try JSONSerialization.data(withJSONObject: dictionaryData, options: [])
            let encodedData = serializedData.base64EncodedString()
            evalJS("initializeEmbed('\(encodedData)');")
            if let metafields = self.metafields {
                setMetaFields(metafields)
            }
        } catch (let error) {
            print("Serialization error: \(error.localizedDescription)")
            return
        }
    }
    
    private func evalJS(_ toRun: String) {
        guard let webView = webView else { return }
        webView.evaluateJavaScript(toRun) { (result, error) in
            if let err = error {
                print(err)
                print(err.localizedDescription)
            } else {
                guard let dataValue = result else { return }
                print(dataValue)
            }
        }
    }
}
