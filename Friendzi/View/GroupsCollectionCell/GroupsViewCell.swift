//
//  GroupsViewCell.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 17.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

class GroupsViewCell: UICollectionViewCell {
    static let reuseIdentifier = "groupsViewCell"
    static let nib = UINib(nibName: "GroupsViewCell", bundle: nil)

    @IBOutlet weak var image: UIImageView? {
        didSet {
            image?.roundView()
        }
    }
}