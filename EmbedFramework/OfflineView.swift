//
//  OfflineView.swift
//  EmbedFramework
//
//  Created by Nicholas Haley on 2019-05-10.
//  Copyright © 2019 Ada Support. All rights reserved.
//

import UIKit

class OfflineView: UIView {
    var label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView(frame: CGRect) {
        label.frame = frame
        label.backgroundColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.text = "You are offline, connect to the internet"
        self.addSubview(label)
    }
}
