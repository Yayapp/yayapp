//
//  Notification.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 11.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

protocol Notification {
    func getPhoto() -> File
    func getTitle() -> String
    func getText() -> String
    func getIcon() -> UIImage

    func isSelectable() -> Bool
    func isDecidable() -> Bool
}