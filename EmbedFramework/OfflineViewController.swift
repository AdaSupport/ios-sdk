//
//  OfflineViewController.swift
//  EmbedFramework
//
//  Created by Aaron Vegh on 2019-06-06.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit

class OfflineViewController: UIViewController {
    
    @IBOutlet var container: UIView!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet weak var noWifiImageView: UIImageView!
    
    var retryBlock: (() -> Void)?
    
    static func create() -> OfflineViewController? {
        let bundle = currentBundle();
        let storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "OfflineViewController") as? OfflineViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retryButton.layer.cornerRadius = 6
        
        let resourceBundle = OfflineViewController.currentBundle()
        noWifiImageView.image = UIImage(named: "no-wifi", in: resourceBundle, compatibleWith: nil)
    }
    
    static func currentBundle() -> Bundle {
        let url = Bundle.main.url(forResource: "AdaEmbedFramework", withExtension: "bundle")!
        return Bundle(url: url) ?? Bundle.main
    }
    
    @IBAction func retryNetworkConnection(sender: UIButton) {
        retryBlock?()
    }
    
}
