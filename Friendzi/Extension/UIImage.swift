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
    
    func resizeToDefault() -> UIImage {
        let size = self.size
        
        if self.size.width > 800 && self.size.height > 600 {
            let widthRatio = 800  / self.size.width
            let heightRatio = 600 / self.size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
            } else {
                newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
       
        } else {
            return self
        }
    }
}
