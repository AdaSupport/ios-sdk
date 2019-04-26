//
//  test.swift
//  EmbedFramework
//
//  Created by Nicholas Haley on 2019-04-23.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit

public class AdaEmbed {
    var handle: String
    var view: UIView
    var webView: EmbedView
    
    public init(handle: String, view: UIView) {
        self.handle = handle
        self.view = view
        self.webView = EmbedView(frame: view.bounds)
        
        addSubview()
    }
    
    public func printHandle() {
        print("Props: \(self.handle)")
    }
    
    public func setMetaFields(fields: [String : Any]) {
        // evaluateJavascript
        print("stuff \(fields)")
    }
    
    private func addSubview() {
        self.view.addSubview(self.webView)
    }
}
