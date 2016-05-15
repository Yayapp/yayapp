//
//  NSDate.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension UIImage {
    func resizedToSize(size: CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;

        let aspectWidth:CGFloat = size.width / size.width;
        let aspectHeight:CGFloat = size.height / size.height;
        let aspectRatio:CGFloat = max(aspectWidth, aspectHeight);

        scaledImageRect.size.width = size.width * aspectRatio;
        scaledImageRect.size.height = size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;

        UIGraphicsBeginImageContextWithOptions(size, false, 0);

        self.drawInRect(scaledImageRect);

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
}
