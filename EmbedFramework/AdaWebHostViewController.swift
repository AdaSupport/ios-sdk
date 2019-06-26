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
    
    static func createWebController(with webView: WKWebView) -> AdaWebHostViewController {
        let bundle = Bundle(for: AdaWebHostViewController.self)
        let storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
        guard let viewController = storyboard.instantiateInitialViewController() as? AdaWebHostViewController else { fatalError("This should never, ever happen.") }
        viewController.webView = webView
        return viewController
    }
    
    static func createNavController(with webView: WKWebView) -> UINavigationController {
        let adaWebHostController = createWebController(with: webView)
        let navController = UINavigationController(rootViewController: adaWebHostController)
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: adaWebHostController, action: #selector(doneButtonTapped(_:)))
        adaWebHostController.title = NSLocalizedString("Ada Support", comment: "")
        adaWebHostController.navigationItem.setLeftBarButton(doneBarButtonItem, animated: false)
        
        return navController
    }
    
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        view = webView
    }
    
    @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdaWebHostViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if #available(iOS 12.0, *) {
            guard let webView = webView else { return }
            for view in webView.subviews {
                if view.isKind(of: NSClassFromString("WKScrollView") ?? UIScrollView.self) {
                    guard let scroller = view as? UIScrollView else { return }
                    scroller.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
        }
    }
    
}
