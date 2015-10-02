//
//  ViewController.swift
//  RobotDemo
//
//  Created by Charles Xia on 5/29/15.
//  Copyright (c) 2015 Charles. All rights reserved.
//

import UIKit
import CoreGraphics



class ViewController: UIViewController,AsyncSocketDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UITextViewDelegate{

    @IBOutlet weak var map_small_image: UIImageView!
    @IBOutlet weak var content_small_view: UIView!
    @IBOutlet weak var scroll_small_view: UIScrollView!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var sendposition: UIButton!
    @IBOutlet weak var robot_point: UIImageView!
    @IBOutlet weak var map_image: UIImageView!
    @IBOutlet weak var robot: UIImageView!
    @IBOutlet weak var console: UITextView!
    @IBOutlet weak var streamInput: UITextField!
    var temp_view:[UIView] = [UIView]()
    var temp_blue_view:UIView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
    var temp_green_view:UIView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
    var robotinsmall: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 3))
    var socket:AsyncSocket = AsyncSocket()
    var last_loc:Int = 0
    var point_position:CGPoint = CGPoint(x: 0,y: 0)
    var robot_position:CGPoint = CGPoint(x: 0, y: 0)
    var temp_point:CGPoint = CGPoint(x:0, y:0)
    var temp_map:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(160000)
    var temp_tag:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(1);
    var temp_small_map:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(3600)
    var temp_x:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var temp_y:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var temp_t:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var temp_astar_x:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1) //red
    var temp_astar_y:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1) //red
    var temp_best_x:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1) //green
    var temp_best_y:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1) //green
    var temp_length:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1) //length
    var temp_point_set:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(20) //point set
    var receive_time:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        var gst = UITapGestureRecognizer(target: self, action:Selector("handleSingleTap:"))
        self.map_image.addGestureRecognizer(gst)
        gst.delegate = self
        socket.setDelegate(self)
        robotinsmall.backgroundColor = UIColor.redColor()
        self.map_small_image.addSubview(self.robotinsmall)
    }
    
    func textViewDidChange(textView: UITextView) {
        textView.scrollRectToVisible(CGRectMake(0, textView.contentSize.height-1, textView.contentSize.width, 5) , animated: true)

    }
    @IBAction func snedToServer(sender: AnyObject) {
        var info:String = streamInput.text
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        self.console.printLog("Send \(info) to Server")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if scrollView.tag == 1{
            return self.contentview
        }else{
            return self.content_small_view
        }
    }
    
    func RobotPointGoTo(){
            self.robot_point.center = point_position
            self.sendposition.center = point_position
            self.sendposition.center.y = self.sendposition.center.y-30
            self.sendposition.alpha = 1
    }
    @IBAction func autoscan(sender: AnyObject) {
        var info:String = "7";
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
    }
    func RobotGoTo(x:Int32, y:Int32){
        var r:CGFloat = self.map_small_image.frame.width / 60
        self.robotinsmall.center.x = CGFloat(Int(x)/50)*r
        self.robotinsmall.center.y = CGFloat(Int(y)/50)*r
    }
    func RobotGoTo(p:CGPoint){
       
        robot_position.x = p.x
        robot_position.y = p.y
        
        if self.robot.center.x != robot_position.x || self.robot.center.y != robot_position.y {
            var y:CGFloat = p.y - self.robot.center.y
            var x:CGFloat = p.x - self.robot.center.x
            if(x > 0){
                self.robot.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2) + atan(y/x))
            }else{
                self.robot.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) + (CGFloat(M_PI/2) - atan(y/(-x))))
            }
            self.robot.center = robot_position
        }
    }
    
    @IBAction func handleSingleTap(recognizer:UITapGestureRecognizer){
        var p:CGPoint = recognizer.locationInView(self.map_image)
        point_position.x = p.x
        point_position.y = p.y
        self.RobotPointGoTo()
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    @IBAction func connect(sender: AnyObject) {
        socket.connectToHost("10.0.0.40", onPort: UInt16(8000), withTimeout: -1, error: nil)
    }
   
    
    func testtest(astar_x:Float, astar_y:Float, best_x:Float, best_y:Float){
        for i in self.map_image.subviews{
            if i.tag == 88 || i.tag == 99{
                i.removeFromSuperview()
            }
        }
        var ratio = self.map_image.frame.width / 400
        var pointset:NSMutableArray = CVWrapper.getAllUncharted(self.temp_map)
        for i in pointset{
            var p:CGPoint = (i as! NSValue).CGPointValue()
            var tempPosition:CGRect = CGRect(x: p.y * ratio, y: p.x * ratio, width: 5, height: 5)
            var tempUV:UIView = UIView(frame: tempPosition)
            tempUV.tag = 88
            tempUV.backgroundColor = UIColor.yellowColor()
            self.map_image.addSubview(tempUV)
        }
        var tempP:UIView = UIView(frame: CGRect(x: self.map_image.frame.origin.x+CGFloat(astar_x), y: self.map_image.frame.origin.y + CGFloat(astar_y), width: 5, height: 5))
        tempP.backgroundColor = UIColor.blueColor()
        tempP.tag = 99
        self.map_image.insertSubview(tempP, aboveSubview: self.robot)
        self.temp_blue_view = tempP
        var tempB:UIView = UIView(frame: CGRect(x: self.map_image.frame.origin.x+CGFloat(best_x), y: self.map_image.frame.origin.y + CGFloat(best_y), width: 5, height: 5))
        tempB.backgroundColor = UIColor.greenColor()
        tempB.tag = 99
        self.map_image.addSubview(tempB)
        self.temp_green_view = tempB

    }
    
    @IBAction func go(sender: AnyObject) {
        var info:String = "1"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        //consoleOutput("Sent:\(info)")
    }
    
    @IBAction func stop(sender: AnyObject) {
        var info:String = "2"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        //consoleOutput("Sent:\(info)")
    }
    @IBAction func scan(sender: AnyObject) {
        var info:String = "3"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        //consoleOutput("Sent:\(info)")
    }
    @IBAction func stopscan(sender: AnyObject) {
        var info:String = "4"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        //consoleOutput("Sent:\(info)")
    }
    @IBAction func startreceiving(sender: AnyObject) {
        self.receive_time = 0
        var info:String = "5"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        //consoleOutput("Sent:\(info)")

    }
    @IBAction func stopreceiving(sender: AnyObject) {
        var info:String = "6"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        //consoleOutput("Sent:\(info)")

    }
    @IBAction func cleanConsole(sender: AnyObject) {
        self.console.text = ""
    }
    func PositionInfo(p:CGPoint)->String{
        return "x:\(p.x) y:\(p.y)"
    }
    
    @IBAction func sendposition(sender: AnyObject) {
        self.sendposition.alpha = 0
        var x:Int = Int(3000*((point_position.x-self.map_image.frame.origin.x)/self.map_image.bounds.size.width))
        var y:Int = Int(3000*((point_position.y-self.map_image.frame.origin.y)/self.map_image.bounds.size.width))
        
        //self.consoleOutput("target point--->x:\(x)y:\(y)")
        var s:String = "\(x)-\(y)" //大地图坐标
        self.socket.writeData(s.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        //print(self.robot_position)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onSocket(sock: AsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        self.console.printLog("Successfully connected to server")
        sock.readDataWithTimeout(-1, tag: 0)
    }
    func onSocket(sock: AsyncSocket!, willDisconnectWithError err: NSError!) {
        self.console.printLog("Disconnected with server")
    }
    func tagAstarPointOnBigMap(length:Int32, p_set:UnsafeMutablePointer<UInt8>){
        for i in self.map_image.subviews{
            if i.tag == 100{
                i.removeFromSuperview()
            }
        }
        
        for i in self.map_small_image.subviews{
            if i.tag == 100{
                i.removeFromSuperview()
            }
        }
        self.temp_view.removeAll(keepCapacity: true)
        var ratio_forbig = self.map_image.frame.width / 60
        var ratio_forsmall = self.map_small_image.frame.width / 60
        var tx:UInt8
        var ty:UInt8
        if length != 0{
        for i in 0...(length-1){
            tx = p_set[Int(i)*2]
            ty = p_set[Int(i)*2+1]
            var tempP:UIView = UIView(frame: CGRect(x: CGFloat(tx)*ratio_forbig, y: CGFloat(ty)*ratio_forbig, width: 3, height: 3))
            tempP.backgroundColor = UIColor.redColor()
            tempP.tag = 100
            var tempS:UIView = UIView(frame: CGRect(x: CGFloat(tx)*ratio_forsmall, y: CGFloat(ty)*ratio_forsmall, width: 2, height: 2))
            tempS.backgroundColor = UIColor.orangeColor()
            tempS.tag = 100
            //self.temp_view.append(tempP)
            self.map_image.insertSubview(tempP, aboveSubview: self.robot)
            self.map_small_image.addSubview(tempS)
            }
        }
//        UIGraphicsBeginImageContext(self.map_image.frame.size)
//        self.map_image.image?.drawInRect(CGRect(x: 0,y: 0,width: self.map_image.frame.size.width, height: self.map_image.frame.size.height))
//        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)  //边缘样式
//        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0) //线宽
//        CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), true)
//        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0) //颜色
//        CGContextBeginPath(UIGraphicsGetCurrentContext())
//        var isfirstpoint:Bool = true
//        if self.temp_view.count >= 2{
//            for i in 0...self.temp_view.count-1{
//                if self.temp_view[i].center.x > 10 && self.temp_view[i].center.y > 10{
//                    if isfirstpoint{
//                    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.temp_view[i].center.x, self.temp_view[i].center.y)
//                        isfirstpoint = false
//                    }else{
//                        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.temp_view[i].center.x, self.temp_view[i].center.y)
//                    }
//                }
//            }
//            
//            if self.temp_blue_view.center.x > 10 && self.temp_blue_view.center.y > 10{
//                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.temp_blue_view.center.x, self.temp_blue_view.center.y)
//            }
//            if self.temp_green_view.center.x > 10 && self.temp_green_view.center.y > 10{
//                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.temp_green_view.center.x, self.temp_green_view.center.y)
//            }
//
//        }
//        
//        CGContextStrokePath(UIGraphicsGetCurrentContext())
//        self.map_image.image=UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
    }
    

    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        //NSLog("Received data: Type: Map Data  Length:%d", data.length)
//        data.getBytes(temp_tag, length: 1)
//        var tag = NSString(bytesNoCopy: temp_tag, length: 1, encoding: NSUTF8StringEncoding, freeWhenDone: false)
//        if tag != "@" {
            if self.last_loc == 0{
                data.getBytes(temp_x, range: NSRange(location: 0, length: 4)) // int x
                data.getBytes(temp_y, range: NSRange(location: 4, length: 4)) // int y
                data.getBytes(temp_t, range: NSRange(location: 8, length: 4)) // int theta
                data.getBytes(temp_astar_x, range:NSRange(location: 12, length: 4))
                data.getBytes(temp_astar_y, range:NSRange(location: 16, length: 4))
                data.getBytes(temp_best_x, range:NSRange(location: 20, length: 4))
                data.getBytes(temp_best_y, range:NSRange(location: 24, length: 4))
                data.getBytes(temp_length, range:NSRange(location: 28, length: 4))
                data.getBytes(temp_point_set, range:NSRange(location: 32, length: 20))
                /* 假如正好传完了前面所有坐标和小地图 */
                if data.length >= 3652{
                    data.getBytes(temp_small_map, range:NSRange(location: 52, length: 3600))
                    /* 假如还收到一点大地图*/
                    if data.length > 3652
                    {
                        data.getBytes(temp_map, range:NSRange(location: 3652, length: data.length-3652))
                    }
                }
                    /* 如果传完了所有小坐标但是没有传完小地图 */
                else{
                    data.getBytes(temp_small_map, range:NSRange(location: 52, length: data.length - 52))
                }
                self.last_loc = data.length
            }else{
                /* 如果小地图没有传完，就接着收 */
                if self.last_loc < 3652{
                    /* 如果小地图传完后还有大地图 */
                    if data.length > (3652 - self.last_loc){
                        data.getBytes(temp_small_map+(self.last_loc-52), length: 3652-self.last_loc)
                        data.getBytes(temp_map, range:NSRange(location: 3652-self.last_loc, length: data.length-(3652-self.last_loc)))
                    }
                    /* 如果这次小地图还是不够 */
                    else{
                        data.getBytes(temp_small_map, length: data.length)
                    }
                }
                    /* 如果小地图传完了 */
                else{
                    data.getBytes(temp_map+(self.last_loc-3652), length: data.length)
                }
                self.last_loc += data.length
            }
            
            if self.last_loc >= 163652{
                var xx:Float = Float(temp_x.memory)
                var yy:Float = Float(temp_y.memory)
                var ratio = Float(self.map_image.bounds.height/3000)
                self.last_loc = 0
                self.receive_time += 1
                temp_point.x = CGFloat(xx*ratio)
                temp_point.y = CGFloat(yy*ratio)
                self.map_image.setImageToMap(temp_map,length: 400)
                self.map_small_image.setImageToMap(temp_small_map, length: 60)
                var xxx:Float = Float(temp_astar_x.memory)*ratio
                var yyy:Float = Float(temp_astar_y.memory)*ratio
                var best_xxx:Float = Float(temp_best_x.memory)*ratio
                var best_yyy:Float = Float(temp_best_y.memory)*ratio
                self.testtest(xxx, astar_y: yyy, best_x: best_xxx, best_y: best_yyy)
                self.RobotGoTo(temp_x.memory, y: temp_y.memory)
                self.RobotGoTo(temp_point)
                self.tagAstarPointOnBigMap(temp_length.memory,p_set: temp_point_set)
                self.console.printLog("Update Map Data \(self.receive_time) Times")
                var info:String = "5"
                self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
            }
            
//        }else{
//            //NSLog("Received data: Type:Message Length:%d", data.length)
//            self.console.printLog("-----")
//
//        }
        sock.readDataWithTimeout(-1, tag: 0)
    }

}
extension UITextView{
    func printLog(s:String!){
        self.insertText(s+"\n")
    }
}

extension UIImageView{
    func setImageToMap(grayArray:UnsafeMutablePointer<UInt8>, length:Int){
        var _image:UIImage = CVWrapper.createUIImageWithArray(grayArray, length: Int32(length))
        UIGraphicsBeginImageContext(self.frame.size)
        _image.drawInRect(CGRect(x: 0,y: 0,width: self.frame.size.width,height: self.frame.size.height))
        var scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = scaledImage
    }
}

