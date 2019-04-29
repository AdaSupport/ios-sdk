//
//  test.swift
//  EmbedFramework
//
//  Created by Nicholas Haley on 2019-04-23.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit
import WebKit

public class AdaEmbed {
    var handle: String
    var view: UIView
    var webView: WKWebView
    
    public init(handle: String, view: UIView) {
        self.handle = handle
        self.view = view
        self.webView = EmbedView(frame: view.bounds).webView
        
        addSubview()
    }
    
    public func printHandle() {
        print("Props: \(self.handle)")
    }
    
    public func setMetaFields(fields: [String : Any]) {
        // evaluateJavascript
        self.webView.evaluateJavaScript("triggerEmbed(\(fields))", completionHandler: nil)
        print("stuff \(self.webView)")
    }
    
    private func addSubview() {
        self.view.addSubview(self.webView)
    }
}
