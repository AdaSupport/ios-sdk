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
    
    public init(handle: String, view: UIView) {
        self.handle = handle
        self.view = view
        
        startView(frame: self.view.bounds)
    }
    
    public func printHandle() {
        print("Props: \(self.handle)")
    }
    
    public func setMetaFields(fields: [String : Any]) {
        // evaluateJavascript
    }
    
    private func startView(frame: CGRect) {
        let embedView = EmbedView(frame: frame)
        self.view.addSubview(embedView)
    }
}
