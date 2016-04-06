//
//  EventPhotoTableViewCell.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class EventPhotoTableViewCell: UITableViewCell {
    static let reuseIdentifier = "eventPhotoTableViewCell"
    static let flatReuseIdentifier = "eventPhotoFlatTableViewCell"
    static let nib = UINib(nibName: "EventPhotoTableViewCell", bundle: nil)
    static let flatNib = UINib(nibName: "EventPhotoFlatTableViewCell", bundle: nil)

    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var photo: UIImageView?

    override func prepareForReuse() {
        super.prepareForReuse()

        name?.text = nil
        photo?.image = nil
    }
}
