//
//  ScriptMessageHandlerWithLeakAvoidance.swift
//  AdaEmbedFramework
//
//  Created by Mike Lazzaro on 2021-03-25.
//  Copyright © 2021 Ada Support. All rights reserved.
//

import WebKit
import Foundation

// This is to allow AdaWebHost to deinit after the events have been removed. Since AdaWebHost contains a strong reference
// for WKScriptMessageHandler this allows us to set a weak reference to the AdaWebHost class when binding with userContentController
class AdaScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            self.delegate?.userContentController(
                userContentController, didReceive: message)
    }
}
