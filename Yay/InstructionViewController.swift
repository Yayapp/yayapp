//
//  InstructionViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 17.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backimage: UIImageView!
    
    var pageIndex : Int = 0
    var titleText : NSAttributedString!
    var imageName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backimage.image = UIImage(named: imageName)
        titleLabel.attributedText = titleText
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
