//
//  EventsTableViewCell.swift
//  Yay
//
//  Created by Nerses Zakoyan on 27.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet var picture: PFImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var howFar: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
