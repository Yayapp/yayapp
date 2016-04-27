//
//  CategoryCollectionViewCell.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "categoryCollectionViewCell"
    static let nib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var switched: UISwitch!

    var onSwitchValueChanged:((isOn: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        name.text = nil
        photo.image = nil
        switched.on = false
        switched.enabled = true
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        onSwitchValueChanged?(isOn: sender.on)
    }
}
