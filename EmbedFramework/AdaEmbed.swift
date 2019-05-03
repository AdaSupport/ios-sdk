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
    var cluster: String
    var language: String
    var styles: String
    var greeting: String
    var view: UIView
    var webView: WKWebView
    var metaFields: [String: String]
    
    public init(
        view: UIView,
        handle: String,
        cluster: String = "",
        language: String = "",
        styles: String = "",
        greeting: String = "",
        metaFields: [String: String]
    ) {
        self.view = view
        self.handle = handle
        self.cluster = cluster
        self.language = language
        self.styles = styles
        self.greeting = greeting
        self.metaFields = metaFields
        self.webView = EmbedView(frame: view.bounds).webView
        
        addSubview()
        
        // Temporary delay until we can recieve event from Embed in HTML when it is loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
            self.initializeEmbed()
        }
    }
    
    public func printHandle() {
        print("Props: \(self.handle)")
    }
    
    public func setMetaFields(fields: [String : Any]) {
        let serializedData = try! JSONSerialization.data(withJSONObject: fields, options: [])
        let encodedData = serializedData.base64EncodedString()
        
        self.webView.evaluateJavaScript("triggerEmbed('\(encodedData)');") { (result, error) in
            if let err = error {
                print(err)
                print(err.localizedDescription)
            } else {
                guard let dataValue = result else {return}
                print(dataValue)
            }
        }
    }
    
    private func initializeEmbed() {
        let serializedData = try! JSONSerialization.data(withJSONObject: [
                "handle": self.handle,
                "cluster": self.cluster,
                "language": self.language,
                "styles": self.styles,
                "greeting": self.greeting,
                "metaFields": self.metaFields
            ], options: [])
        let encodedData = serializedData.base64EncodedString()
        
        self.webView.evaluateJavaScript("initializeEmbed('\(encodedData)');") { (result, error) in
            if let err = error {
                print(err)
                print(err.localizedDescription)
            } else {
                guard let dataValue = result else {return}
                print(dataValue)
            }
        }
    }
    
    private func addSubview() {
        self.view.addSubview(self.webView)
    }
}
