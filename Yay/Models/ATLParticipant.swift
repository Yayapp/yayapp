//
//  ATLParticipant.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 11.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

extension PFUser: ATLParticipant {
    
    public var firstName: String {
        return self.objectForKey("name")! as! String
    }
    
    public var lastName: String {
        return ""
    }
    
    public var fullName: String {
        return "\(self.firstName)"
    }
    
    public var participantIdentifier: String {
        return self.objectId!
    }
    
    public var avatarImageURL: NSURL? {
        return nil
    }
    
    public var avatarImage: UIImage? {
        return nil
    }
    
    public var avatarInitials: String {
        let initials = "\(getFirstCharacter(self.firstName))\(getFirstCharacter(self.lastName))"
        return initials.uppercaseString
    }
    
    private func getFirstCharacter(value: String) -> String {
        return (value as NSString).substringToIndex(1)
    }
}