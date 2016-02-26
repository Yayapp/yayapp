//
//  StartViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var dots: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    
    @IBAction func login(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        vc.isLogin = true
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func signup(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        presentViewController(vc, animated: true, completion: nil)
    }
   
    
   
}
