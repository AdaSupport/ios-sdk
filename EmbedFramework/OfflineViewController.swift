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
    
    static func create() -> OfflineViewController? {
        let bundle = Bundle(for: OfflineViewController.self)
        let storyboard = UIStoryboard(name: "AdaWebHostViewController", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "OfflineViewController") as? OfflineViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        container.layer.borderColor = UIColor.black.cgColor
//        container.layer.borderWidth = 2.0
//        container.layer.cornerRadius = 5.0
    }
    
}
