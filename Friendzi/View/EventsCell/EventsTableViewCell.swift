//
//  EventsTableViewCell.swift
//  Yay
//
//  Created by Nerses Zakoyan on 27.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

final class EventsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "eventsTableViewCell"
    static let nib = UINib(nibName: "EventsTableViewCell", bundle: nil)

    @IBOutlet weak var picture: UIImageView?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var location: UILabel?
    @IBOutlet weak var date: UILabel?
    @IBOutlet weak var howFar: UILabel?
    @IBOutlet weak var author: UIButton?
    @IBOutlet weak var attended1: UIButton?
    @IBOutlet weak var attended2: UIButton?
    @IBOutlet weak var attended3: UIButton?
    @IBOutlet weak var attended4: UIButton?

    var attendeesButtons: [UIButton?]?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        picture?.image = nil
        title?.text = nil
        location?.text = NSLocalizedString("Loading location...", comment: "")
        date?.text = nil
        howFar?.text = nil

        for button in [author, attended1, attended2, attended3, attended4] {
            button?.setImage(nil, forState: .Normal)

            button?.hidden = button != author
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if self.attendeesButtons == nil {
            return
        }
        
        for button in attendeesButtons! {
            button?.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if self.attendeesButtons == nil {
            return
        }
        
        for button in attendeesButtons! {
            button?.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
        }
    }
}

private extension EventsTableViewCell {
    //Mark: - UI Setup 
    func setupUI() {
        if self.attendeesButtons != nil {
            return
        }

        let attendeesButtons = [author, attended1, attended2, attended3, attended4]

        for button in attendeesButtons {
            button?.layer.cornerRadius = (button?.bounds.height ?? 0) / 2
            button?.imageView?.contentMode = .ScaleAspectFill
            button?.clipsToBounds = true
            button?.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
        }

        self.attendeesButtons = attendeesButtons
    }
}
