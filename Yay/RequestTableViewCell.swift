//
//  RequestTableViewCell.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    
    @IBOutlet var avatar: PFImageView!
    @IBOutlet var eventName: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var accept: UIButton!
    @IBOutlet var decline: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
