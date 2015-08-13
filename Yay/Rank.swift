//
//  Rank.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 13.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

enum Rank {
    
    case KID, POPULAR, BUTTERFLY, SOCIALITE
    
    func getString(gender:Int) -> String {
        switch self {
        case KID:
            return "New kid on the block"
        case POPULAR:
            return gender == 1 ? "Mr. Popular" : "Mrs. Popular"
        case BUTTERFLY:
            return "Social butterfly"
        case SOCIALITE:
            return "Socialite"
            
        }
    }
    
    func getImage(gender:Int) -> UIImage {
        switch self {
        case KID:
            return UIImage(named: gender == 0 ? "newfemale_kid_in_blockrank" : "newkid_rank")!
        case POPULAR:
            return UIImage(named: gender == 0 ? "mrspopular" : "mrpopularicon")!
        case BUTTERFLY:
            return UIImage(named: "socialbuttefly_rank")!
        case SOCIALITE:
            return UIImage(named: gender == 0 ? "socialite_female_rank" : "socialiterank")!
        
        }
    }
    
    static func getRank(count:Int) -> Rank {
        if count <= 5 {
            return KID
        } else if count > 5 && count <= 20 {
            return POPULAR
        } else if count > 20 && count <= 50 {
            return BUTTERFLY
        } else {
            return SOCIALITE
        }
    }
}
