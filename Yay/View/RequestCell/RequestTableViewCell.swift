//
//  RequestTableViewCell.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    static let reuseIdentifier = "requestTableViewCell"
    static let nib = UINib(nibName: "RequestTableViewCell", bundle: nil)

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var accept: UIButton!
    @IBOutlet weak var decline: UIButton!
}
