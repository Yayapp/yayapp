//
//  RangeViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class RangeViewController: UIViewController {

    @IBOutlet private weak var rangeText: UILabel!
    @IBOutlet private weak var rangeSelector: UISlider!

    private var currentValue: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        currentValue = ParseHelper.sharedInstance.currentUser?.distance
        rangeText.text = "\(currentValue)KM"
        rangeSelector.value = Float(currentValue)
        // Do any additional setup after loading the view.
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        currentValue = Int(sender.value)
        rangeText.text = "\(Int(currentValue))KM"
    }

    @IBAction func doneAction(sender: AnyObject) {
        ParseHelper.sharedInstance.currentUser?.distance = currentValue
        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
}
