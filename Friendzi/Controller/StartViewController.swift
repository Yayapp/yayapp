//
//  StartViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

final class StartViewController: UIViewController {
    
    @IBOutlet private weak var dots: UIPageControl?

    @IBAction func login(sender: AnyObject) {
        guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
            return
        }

        vc.isLogin = true
        presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func signup(sender: AnyObject) {
        guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
            return
        }

        presentViewController(vc, animated: true, completion: nil)
    }
}
