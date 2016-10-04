//
//  RegisterUserVC.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 04/10/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
class RegisterUserVC: UIViewController , ClickeyServiceConsumer{

    @IBOutlet var userName: UITextField?
    @IBOutlet var password: UITextField?
    @IBOutlet var email: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            
        #endif
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func registerUser(sender: AnyObject?) {
        if let password = password?.text, let userName = userName?.text, let email = email?.text {
        service.registerUser(userName, password: password, email: email) { result in
                
            }
        }
    }
}
