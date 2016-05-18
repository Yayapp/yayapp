//
//  String.swift
//  Friendzi
//
//  Created by Erison on 5/11/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension String {

    /**
     Returns the localized version of self.
     */
    var localized: String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: NSBundle.mainBundle(),
                                 value: "",
                                 comment: "")
    }
    
    func MD5() -> String {
        let data = (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))
        let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result!.mutableBytes)
        CC_MD5(data!.bytes, CC_LONG(data!.length), resultBytes)
        
        let buff = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result!.length)
        let hash = NSMutableString()
        for i in buff {
            hash.appendFormat("%02x", i)
        }
        return hash as String
    }
    
    func isEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$",
                                             options: [.CaseInsensitive])
        
        return regex.firstMatchInString(self, options:[],
                                        range: NSMakeRange(0, utf16.count)) != nil
    }
}