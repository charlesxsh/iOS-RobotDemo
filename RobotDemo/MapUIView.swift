//
//  MapUIView.swift
//  RobotDemo
//
//  Created by Charles Xia on 6/3/15.
//  Copyright (c) 2015 Charles. All rights reserved.
//

import UIKit

class MapUIView:UIView {
    //var rectCollect = [CGPoint]()
    //var imageCollect = [UIImage]()
    //var tp:CGPoint = CGPoint()
    var ti:UIImage = UIImage()
    var robot:CGPoint = CGPoint()
    var p_flag:Int = 0
    
    func drawpoint(r:CGPoint){
        self.p_flag = 1
        self.robot = r
        self.setNeedsDisplay()
    }
    
    func updateView(ti:UIImage){
        self.ti = ti
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        var ratio = self.bounds.size.height / 3000
        var len = 300 * ratio
        var context:CGContextRef  = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, CGRectMake(0, 0, self.bounds.width, self.bounds.height), ti.CGImage)
        if p_flag == 1{
            CGContextAddArc(context, robot.x, robot.y,CGFloat(5), CGFloat(0), CGFloat(2*M_PI), 0)
            CGContextDrawPath(context, kCGPathFill)
        }
//        if imageCollect.count > 0{
//            for i in 0...imageCollect.count-1{
//                var TargetRect = CGRectMake(rectCollect[i].x - (len/2), rectCollect[i].y - (len/2), len, len)
//                CGContextDrawImage(context, TargetRect, imageCollect[i].CGImage)
//            }
//        }
//        print("一共渲染\(self.imageCollect.count)张")
    }
}
