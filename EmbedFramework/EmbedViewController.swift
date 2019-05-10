//
//  EmbedViewController.swift
//  EmbedFramework
//
//  Created by Nicholas Haley on 2019-05-09.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit

public class EmbedViewController: UIViewController {
    
    let network: NetworkManager = NetworkManager.sharedInstance
    var parentView: UIView
    var actionStack: [String]
    var handle: String
    var cluster: String
    var language: String
    var styles: String
    var greeting: String
    var metaFields: [String: String]
    var isEmbedReady: Bool
    
    convenience init() {
        self.init(
            parentView: UIView(),
            handle: "",
            cluster: "",
            language: "",
            styles: "",
            greeting: "",
            metaFields: [:]
        )
    }
    
    public init(
        parentView: UIView,
        handle: String,
        cluster: String,
        language: String,
        styles: String,
        greeting: String,
        metaFields: [String: String]
    ) {
        self.parentView = parentView
        self.handle = handle
        self.cluster = cluster
        self.language = language
        self.styles = styles
        self.greeting = greeting
        self.metaFields = metaFields
        self.isEmbedReady = false
        self.actionStack = []

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // if this view controller is loaded from a storyboard, imageURL will be nil
    
    /* Xcode 6
     required init(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
     }
     */

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
