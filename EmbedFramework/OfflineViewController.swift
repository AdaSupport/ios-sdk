//
//  OfflineViewController.swift
//  EmbedFramework
//
//  Created by Aaron Vegh on 2019-06-06.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit

@objc(OfflineViewController)
class OfflineViewController: UIViewController {
    
    @IBOutlet var container: UIView!
    @IBOutlet var retryButton: UIButton!
    
    var retryBlock: (() -> Void)?
    
    static func create() -> OfflineViewController? {
        var storyboard:UIStoryboard
      
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
      
        #else
        let bundle = Bundle(for: OfflineViewController.self)
        
        // Loads the resource_bundle if available (Cocoapod)
        if (bundle.path(forResource: "AdaEmbedFramework", ofType: "bundle") != nil){
            let frameworkBundlePath = bundle.path(forResource: "AdaEmbedFramework", ofType: "bundle")!
            let frameworkBundle = Bundle(path: frameworkBundlePath)
            storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: frameworkBundle)
        } else {
            // Used for if SDK was manually imported
            storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
        }
        #endif
      
        return storyboard.instantiateViewController(withIdentifier: "OfflineViewController") as? OfflineViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retryButton.layer.cornerRadius = 6
    }
    
    @IBAction func retryNetworkConnection(sender: UIButton) {
        retryBlock?()
    }
    
}
