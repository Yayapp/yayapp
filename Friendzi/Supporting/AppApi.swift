//
//  AppApi.swift
//  Friendzi
//
//  Created by Codemagnus on 6/24/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import MobileCoreServices

private let baseURLString : String = "http://40.69.32.246:3000/"

class AppAPI: NSObject {
    
    static let sharedAppAPI : AppAPI = AppAPI()
    typealias convenienceHandler = (returnObject: AnyObject?, error: NSError?) -> Void
    
    
    private lazy var operationHandler: NSOperationQueue = {
        
        let operation = NSOperationQueue()
        operation.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
        
        return operation
        
    }()
    
    lazy var uploadSessionQueue: NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.suspended = false
        
        if operationQueue.respondsToSelector(Selector("qualityOfService")) {
            operationQueue.qualityOfService = NSQualityOfService.Utility
        }
        
        return operationQueue
    }()
    
    
    func deviceTag(params : [String : String],  completion: convenienceHandler) {
        let appTag = baseURLString + "users/registerDeviceToken"
        
        Alamofire.request(.POST, appTag, parameters: params, encoding: .JSON, headers: nil).responseJSON { (responseObject) -> Void in
            
            completion(returnObject: responseObject.result.value, error: responseObject.result.error)
        }
    }
}
