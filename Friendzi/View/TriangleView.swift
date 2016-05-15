//
//  TriangleView.swift
//  Friendzi
//
//  Created by Yuriy B. on 5/4/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

//TODO: - Move it to UIView extension
import UIKit

class TriangleView: UIView {
    override func drawRect(rect: CGRect) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowRadius = 1
        layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.6).CGColor
        layer.shadowOpacity = 1

        let ctx = UIGraphicsGetCurrentContext()

        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect))
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextClosePath(ctx)

        CGContextSetRGBFillColor(ctx, 0.98, 0.99, 0.99, 1)
        CGContextFillPath(ctx)
    }
}