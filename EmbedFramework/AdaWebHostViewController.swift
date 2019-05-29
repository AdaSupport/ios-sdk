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
    
    static func createNavController(with webView: WKWebView) -> UINavigationController {
        let bundle = Bundle(for: AdaWebHostViewController.self)
        let storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
        guard
            let navController = storyboard.instantiateInitialViewController() as? UINavigationController,
            let viewController = navController.topViewController as? AdaWebHostViewController else { fatalError("This should never, ever happen.") }
        viewController.webView = webView
        return navController
    }
    
    static func createWebController(with webView: WKWebView) -> AdaWebHostViewController {
        let bundle = Bundle(for: AdaWebHostViewController.self)
        let storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "adaWebHostViewController") as? AdaWebHostViewController else { fatalError("This should never, ever happen.") }
        viewController.webView = webView
        return viewController
    }
    
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        view = webView
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        guard let navController = navigationController else { return }
        if navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
