//
//  ATLParticipant.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 11.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

extension User {

    var participantIdentifier: String {
        return self.objectId!
    }

    var avatarImageURL: NSURL? {
        if let avatar = self.avatar {
            return NSURL(string:avatar.url!)
        }

        return nil
    }

    var avatarImage: UIImage? {
        return nil
    }

}
