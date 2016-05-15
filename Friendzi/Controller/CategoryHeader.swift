//
//  CategoryHeader.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 07.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import UIKit

class CategoryHeader: UICollectionReusableView {
    static let reuseIdentifier = "CategoryHeader"
    
    @IBOutlet weak var name: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        name.text = nil
    }
}