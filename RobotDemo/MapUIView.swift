//
//  MapUIView.swift
//  RobotDemo
//
//  Created by Charles Xia on 6/3/15.
//  Copyright (c) 2015 Charles. All rights reserved.
//

import UIKit

class MapUIView:UIView {
    var rectCollect = [CGPoint]()
    var imageCollect = [UIImage]()
    var tp:CGPoint = CGPoint()
    var ti:UIImage = UIImage()
    func updateView(tp:CGPoint, ti:UIImage){
        rectCollect.append(tp)
        imageCollect.append(ti)
        self.tp = tp
        self.ti = ti
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        var ratio = self.bounds.size.height / 3000
        var len = 300 * ratio
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        if imageCollect.count > 0{
            for i in 0...imageCollect.count-1{
                var TargetRect = CGRectMake(rectCollect[i].x - (len/2), rectCollect[i].y - (len/2), len, len)
                CGContextDrawImage(context, TargetRect, imageCollect[i].CGImage)
            }
        }
        print("一共渲染\(self.imageCollect.count)张")
    }
}
