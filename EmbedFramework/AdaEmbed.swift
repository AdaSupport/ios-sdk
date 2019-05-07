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
    var view: UIView
    var embed: EmbedView
    var actionStack: [String]
    
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
        self.actionStack = []
        self.embed = EmbedView(
            frame: view.bounds,
            handle: handle,
            cluster: cluster,
            language: language,
            styles: styles,
            greeting: greeting,
            metaFields: metaFields
        )
        
        addSubview()
    }
    
    public func setMetaFields(fields: [String : Any]) {
        let serializedData = try! JSONSerialization.data(withJSONObject: fields, options: [])
        let encodedData = serializedData.base64EncodedString()
        let toRun = "setMetaFields('\(encodedData)');"
        
        if !self.embed.isEmbedReady {
            self.actionStack.append(toRun)
            return
        }
        
        self.evalJS(toRun)
    }
    
    private func evalJS(_ toRun: String) {
        self.embed.webView.evaluateJavaScript(toRun) { (result, error) in
            if let err = error {
                print(err)
                print(err.localizedDescription)
            } else {
                print("yolo")
                guard let dataValue = result else {return}
                print(dataValue)
            }
        }
    }

    private func addSubview() {
        self.view.addSubview(self.embed.webView)
    }
}
