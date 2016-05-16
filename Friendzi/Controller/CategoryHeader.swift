//
//  CategoryHeader.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 07.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import UIKit

//TODO:- Move to view
final class CategoryHeader: UICollectionReusableView {
    static let reuseIdentifier = "CategoryHeader"
    
    @IBOutlet private weak var nameLabel: UILabel?

    var name: String? {
        didSet {
            guard let name = name else {
                return
            }
            nameLabel?.text = name
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel?.text = ""
    }
}