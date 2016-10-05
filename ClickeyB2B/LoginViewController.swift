//
//  ViewController.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 22/09/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController , ClickeyServiceConsumer{

    @IBOutlet var userName: UITextField?
    @IBOutlet var password: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            
        #endif
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func login(sender: AnyObject?) {
        if let password = password?.text, let userName = userName?.text {
            KeychainManager.sharedInstance.setPassword(password)
            KeychainManager.sharedInstance.saveUserID(userName)
            service.authenticate(userName, password: password) { result in
                if result.isSuccess {
                    NSNotificationCenter.defaultCenter().postNotificationName("getDevices", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("registerForNotifications", object: nil)
                }
            }
        }
    }
    
    @IBAction func register(sender: AnyObject?) {
        self.performSegueWithIdentifier(R.segue.loginViewController.registeruser, sender: self)
    }

}

