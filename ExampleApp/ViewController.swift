//
//  ViewController.swift
//  ExampleApp
//
//  Created by Aaron Vegh on 2019-05-14.
//  Copyright © 2019 Aaron Vegh. All rights reserved.
//

import UIKit
import EmbedFramework

class ViewController: UIViewController {
    
    var adaFramework = AdaWebHost()
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var adaSupportButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func submitForm(_ sender: UIButton) {
        guard
            let firstName = firstNameField.text,
            let lastName = lastNameField.text,
            let email = emailField.text else { return }
        
        adaFramework.setMetaFields([
            "firstName": firstName,
            "lastName": lastName,
            "email": email])
    }
    
    @IBAction func openSupport(_ sender: UIButton) {
        adaFramework.launchWebSupport(from: self)
    }
}
