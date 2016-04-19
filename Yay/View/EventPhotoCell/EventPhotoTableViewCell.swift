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
    @IBOutlet weak var activityPlaceholderView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    func showActivityIndicator() {
        activityPlaceholderView.hidden = false
        activityIndicatorView.startAnimating()
    }

    func hideActivityIndicator() {
        activityPlaceholderView.hidden = true
        activityIndicatorView.stopAnimating()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        activityPlaceholderView.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        name?.text = nil
        photo?.image = nil
        activityPlaceholderView.hidden = true
        activityIndicatorView.stopAnimating()
    }
}
