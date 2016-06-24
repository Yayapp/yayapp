//
//  SocketIOManager.swift
//  Friendzi
//
//  Created by Codemagnus on 6/24/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import UIKit
import SocketIOClientSwift

private var id = (ParseHelper.sharedInstance.currentUser?.id!)!
private var token = (NSUserDefaults.standardUserDefaults().objectForKey("token") as? String)!

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://40.69.32.246:3000")!, options: [.Log(true), .ForcePolling(true), .ConnectParams(["id":id, "tag":token])])
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        
        socket.connect()
    }
    
    func disconnetConnection() {
        
        socket.disconnect()
    }
}

