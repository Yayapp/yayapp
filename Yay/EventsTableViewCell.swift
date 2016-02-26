//
//  EventsTableViewCell.swift
//  Yay
//
//  Created by Nerses Zakoyan on 27.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet weak var picture: PFImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var howFar: UILabel!
    
    @IBOutlet weak var author: UIButton!
    
    @IBOutlet weak var attended1: UIButton!
    
    @IBOutlet weak var attended2: UIButton!
    
    @IBOutlet weak var attended3: UIButton!
    
    @IBOutlet weak var attended4: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        author.layer.cornerRadius = author.frame.width/2
        attended1.layer.cornerRadius = attended1.frame.width/2
        attended2.layer.cornerRadius = attended2.frame.width/2
        attended3.layer.cornerRadius = attended3.frame.width/2
        attended4.layer.cornerRadius = attended4.frame.width/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
