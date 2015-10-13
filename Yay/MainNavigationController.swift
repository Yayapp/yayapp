//
//  MainNavigationControllerViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = navigationBar
        nav.barTintColor = Color.DefaultBarColor
        
        // Do any additional setup after loading the view.
    }
}
