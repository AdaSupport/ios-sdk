//
//  EmbedFrameworkView.swift
//  EmbedFramework
//
//  Created by Nicholas Haley on 2019-04-23.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit
import WebKit

public class EmbedView: UIView {
    
    public override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        setUpView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        print("Bounds: \(self.frame)")
        let webView = WKWebView(frame: self.frame, configuration: WKWebViewConfiguration())
        addSubview(webView)
        
        // This isn't working yet :(
        let bundle = Bundle.init(identifier: "com.ada.EmbedFramework")
        print(bundle as Any)
        if let htmlPath = bundle?.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
