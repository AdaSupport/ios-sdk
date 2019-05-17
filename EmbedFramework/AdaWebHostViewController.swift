//
//  AdaWebHostViewController.swift
//  EmbedFramework
//
//  Created by Aaron Vegh on 2019-05-17.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit
import WebKit

class AdaWebHostViewController: UIViewController {
    
    static func create(with webView: WKWebView) -> UINavigationController {
        let bundle = Bundle(for: AdaWebHostViewController.self)
        let storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
        guard
            let navController = storyboard.instantiateInitialViewController() as? UINavigationController,
            let viewController = navController.topViewController as? AdaWebHostViewController else { fatalError("This should never, ever happen.") }
        viewController.webView = webView
        return navController
    }
    
    @IBOutlet var webView: WKWebView!
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
