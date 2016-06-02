//
//  RangeViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class RangeViewController: UIViewController {

    @IBOutlet private weak var rangeText: UILabel?
    @IBOutlet private weak var rangeSelector: UISlider?

    private var currentValue: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        currentValue = ParseHelper.sharedInstance.currentUser?.distance
        rangeText?.text = "\(currentValue ?? 20)KM"
        if let value = currentValue {
            rangeSelector?.value = Float(value)
        }
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        currentValue = Int(sender.value)
         if let value = currentValue {
            rangeText?.text = "\(Int(value))KM"
        }
    }

    @IBAction func doneAction(sender: AnyObject) {
        ParseHelper.sharedInstance.currentUser?.distance = currentValue
        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
}
