//
//  ChooseDateTimeViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 17.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

protocol ChooseDateDelegate : NSObjectProtocol {
    func madeDateTimeChoice(date: NSDate)
}

class ChooseDateTimeViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: ChooseDateDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func ok(sender: AnyObject) {
        delegate.madeDateTimeChoice(datePicker.date)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
