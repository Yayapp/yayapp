//
//  RangeViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class RangeViewController: UIViewController {

    @IBOutlet weak var rangeText: UILabel!
    
    @IBOutlet weak var rangeSelector: UISlider!
    
    var currentValue:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentValue = PFUser.currentUser()?.objectForKey("distance") as! Int
        rangeText.text = "\(currentValue)KM"
        rangeSelector.value = Float(currentValue)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        currentValue = Int(sender.value)
        rangeText.text = "\(Int(currentValue))KM"
    }
    @IBAction func doneAction(sender: AnyObject) {
        PFUser.currentUser()?.setObject(currentValue, forKey: "distance")
        PFUser.currentUser()?.saveInBackground()
        
        navigationController?.popViewControllerAnimated(true)
    }

    

}
