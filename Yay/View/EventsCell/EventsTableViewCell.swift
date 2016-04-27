//
//  EventsTableViewCell.swift
//  Yay
//
//  Created by Nerses Zakoyan on 27.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "eventsTableViewCell"
    static let nib = UINib(nibName: "EventsTableViewCell", bundle: nil)

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var howFar: UILabel!

    @IBOutlet weak var author: UIButton!

    @IBOutlet weak var attended1: UIButton!

    @IBOutlet weak var attended2: UIButton!

    @IBOutlet weak var attended3: UIButton!

    @IBOutlet weak var attended4: UIButton!

    var attendeesButtons: [UIButton!]?

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.attendeesButtons != nil {
            return
        }

        let attendeesButtons = [author, attended1, attended2, attended3, attended4]

        for button in attendeesButtons {
            button.setNeedsLayout()
            button.layoutIfNeeded()
            button.layer.cornerRadius = author.bounds.width / 2
        }

        self.attendeesButtons = attendeesButtons
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        picture.image = nil
        title.text = nil
        location.text = NSLocalizedString("Loading location...", comment: "")
        date.text = nil
        howFar.text = nil

        for button in [author, attended1, attended2, attended3, attended4] {
            button.setImage(nil, forState: .Normal)
        }
    }
}
