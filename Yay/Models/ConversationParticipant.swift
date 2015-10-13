//
//  ATLParticipant.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 11.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

extension PFUser {
    
    public var name: String {
        return self.objectForKey("name")! as! String
    }
    
    public var participantIdentifier: String {
        return self.objectId!
    }
    
    public var avatarImageURL: NSURL? {
        if let avatar = self.objectForKey("avatar") as? PFFile {
            return NSURL(string:avatar.url!)
        }
        return nil
    }
    
    public var avatarImage: UIImage? {
        return nil
    }
    
}