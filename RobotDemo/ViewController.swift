//
//  ViewController.swift
//  RobotDemo
//
//  Created by Charles Xia on 5/29/15.
//  Copyright (c) 2015 Charles. All rights reserved.
//

import UIKit
import CoreGraphics
var point_position:CGPoint = CGPoint(x: 0,y: 0)


class ViewController: UIViewController,AsyncSocketDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate{

    @IBOutlet weak var limitinput: UITextField!
    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var scroll_view: UIScrollView!

    @IBOutlet weak var sendposition: UIButton!
    @IBOutlet weak var robot_point: UIImageView!
    @IBOutlet weak var map_image: UIImageView!
    @IBOutlet weak var robot: UIImageView!
    @IBOutlet weak var console: UITextView!
    @IBOutlet weak var hostTextfield: UITextField!
    @IBOutlet weak var portTextfield: UITextField!
    @IBOutlet weak var streamInput: UITextField!
    var button_sendp_orig:CGPoint = CGPoint()
    //var oldFrame:CGRect = CGRect()
    //var largeFrame:CGRect = CGRect()
    var tempPoint:CGPoint = CGPoint()
    var socket:AsyncSocket = AsyncSocket()
    var image_data:CVWrapper = CVWrapper()
    var last_loc:Int = 0
    var robot_position:CGPoint = CGPoint(x: 0, y: 0)
    var temp_point:CGPoint = CGPoint(x:0, y:0)
    var temp_map:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(160000)
    var temp_x:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var temp_y:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var temp_t:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var receive_time:Int = 0
    var i_ratio:Float = 0.0
    var robot_point_temp_x:CGFloat = 0.0
    var robot_point_temp_y:CGFloat = 0.0
    var temp_uiview_set:[UIView] = [UIView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostTextfield.text = "10.0.0.40"
        self.portTextfield.text = "8000"
        self.streamInput.text = "3"
        var gst = UITapGestureRecognizer(target: self, action:Selector("handleSingleTap:"))
        //var pinch = UIPinchGestureRecognizer(target: self, action: Selector("pinchView:"))
        //var pan = UIPanGestureRecognizer(target: self, action: Selector("panView:"))
        //self.map_image.addGestureRecognizer(pinch)
        self.map_image.addGestureRecognizer(gst)
        //self.map_image.addGestureRecognizer(pan)
        //pinch.delegate = self
        gst.delegate = self
        //pan.delegate = self
        //println(self.map_image.bounds)
        socket.setDelegate(self)
    }
    
    @IBAction func snedToServer(sender: AnyObject) {
        var info:String = streamInput.text
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.contentview
    }
    
    func RobotPointGoTo(){

            self.robot_point.center = point_position
            self.sendposition.center = point_position
            self.sendposition.center.y = self.sendposition.center.y-30
            self.sendposition.alpha = 1
    }
    
    func RobotGoTo(p:CGPoint){
        robot_position.x = self.map_image.frame.origin.x+p.x
        robot_position.y = self.map_image.frame.origin.y+p.y
        
        if self.robot.center.x != robot_position.x || self.robot.center.y != robot_position.y {
            var y:CGFloat = self.map_image.frame.origin.y+p.y - self.robot.center.y
            var x:CGFloat = self.map_image.frame.origin.x+p.x - self.robot.center.x
            if(x > 0){
                self.robot.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2) + atan(y/x))
            }else{
                self.robot.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) + (CGFloat(M_PI/2) - atan(y/(-x))))
            }
            self.robot.center = robot_position
        }
    }

    //缩放函数
    @IBAction func pinchView(recognizer:UIPinchGestureRecognizer){
        var view:UIView = recognizer.view!
        //var temp:CGPoint = view.frame.origin
        if recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Changed{
            
            if recognizer.scale < 1{
                self.map_image.center = CGPoint(x: self.scroll_view.bounds.midX, y: self.scroll_view.bounds.midY)

               // var diff_x = view.frame.origin.x - temp.x
                //var diff_y = view.frame.origin.y - temp.y
                
                //self.robot_point.center.x = self.robot_point.center.x + (diff_x/recognizer.scale)
                //self.robot_point.center.y = self.robot_point.center.y + (diff_y/recognizer.scale)
                    view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale)
                    if self.map_image.frame.size.width < self.scroll_view.bounds.size.width{
                        self.map_image.frame = self.scroll_view.bounds
                        view.transform = CGAffineTransformMakeScale(1, 1)
                    }

                
            }else{
                view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale)
                //var diff_x = view.frame.origin.x - temp.x
                //var diff_y = view.frame.origin.y - temp.y
                //self.robot_point.center.x = self.robot_point.center.x+diff_x*recognizer.scale
                //self.robot_point.center.y = self.robot_point.center.y+diff_y*recognizer.scale
            }
            recognizer.scale = 1
        }
    }
    
    //移动函数
    @IBAction func panView(recognizer:UIPanGestureRecognizer){
        var view:UIView = recognizer.view!
        if (recognizer.state == .Began || recognizer.state == .Changed) && self.map_image.frame != self.scroll_view.bounds{
            var trans:CGPoint = recognizer.translationInView(view.superview!)
            view.center = CGPoint(x: view.center.x+trans.x,y: view.center.y+trans.y)
            recognizer.setTranslation(CGPointZero, inView: view.superview)
            /* 防止图片小于区域尺寸 */
            if self.map_image.frame.origin.x > 0{
                self.map_image.frame.origin.x = 0
            }
            if self.map_image.frame.origin.y > 0{
                self.map_image.frame.origin.y = 0
            }
            if self.map_image.frame.maxX < self.scroll_view.bounds.maxX{
                self.map_image.frame.origin.x = self.scroll_view.bounds.maxX-self.map_image.frame.width
            }
            if self.map_image.frame.maxY < self.scroll_view.bounds.maxY{
                self.map_image.frame.origin.y = self.scroll_view.bounds.maxY - self.map_image.frame.height
            }
            /*-----------------------*/
        }
        
    }

    @IBAction func handleSingleTap(recognizer:UITapGestureRecognizer){
        var p:CGPoint = recognizer.locationInView(self.map_image)
        println(p)
        point_position.x = p.x
        point_position.y = p.y
        self.RobotPointGoTo()
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func consoleOutput(s:String){
        console.text  = s+"\n"+console.text
    }
    @IBAction func connect(sender: AnyObject) {
        socket.connectToHost(hostTextfield.text, onPort: UInt16(portTextfield.text.toInt()!), withTimeout: 3, error: nil)
    }
   
    @IBAction func testuiimage(sender: AnyObject) {
        println("here")
    }
    
    func testtest(){
        if self.contentview.subviews.count > 3{
            for i in self.contentview.subviews{
                if i.backgroundColor == UIColor.yellowColor(){
                    i.removeFromSuperview()
                }
            }
        }
        var ratio = self.map_image.frame.width / 400
        var pointset:NSMutableArray = CVWrapper.getAllUncharted(self.temp_map)
        println("Total find \(pointset.count) Points")
        for i in pointset{
            var p:CGPoint = (i as! NSValue).CGPointValue()
            var tempPosition:CGRect = CGRect(x: p.y * ratio, y: p.x * ratio, width: 5, height: 5)
            var tempUV:UIView = UIView(frame: tempPosition)
            tempUV.backgroundColor = UIColor.yellowColor()
            self.contentview.insertSubview(tempUV, aboveSubview: self.map_image)
        }

    }
    
    @IBAction func go(sender: AnyObject) {
        var info:String = "1"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")
    }
    
    @IBAction func stop(sender: AnyObject) {
        var info:String = "2"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")
    }
    @IBAction func scan(sender: AnyObject) {
        var info:String = "3"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")
    }
    @IBAction func stopscan(sender: AnyObject) {
        var info:String = "4"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")
    }
    @IBAction func startreceiving(sender: AnyObject) {
        self.receive_time = 0
        var info:String = "5"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")

    }
    @IBAction func stopreceiving(sender: AnyObject) {
        var info:String = "6"
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")

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
        consoleOutput("Success connect to \(host):\(port)")
        sock.readDataWithTimeout(-1, tag: 0)
    }
    func onSocket(sock: AsyncSocket!, willDisconnectWithError err: NSError!) {
        consoleOutput("Will disconnect.")
    }
    
    //如果图片要缩放，使用这个方法创建图片
    func createImagewithArray(grayArray:UnsafeMutablePointer<UInt8>)->UIImage{
        var origImage:UIImage = CVWrapper.createUIImageWithArray(grayArray)
        var ratio = self.map_image.bounds.size.width/3000
        var length = 400*ratio
        var targetRect = CGRect(x: 0, y: 0, width: length, height: length)
        UIGraphicsBeginImageContext(CGSize(width: length, height: length))
        origImage.drawInRect(targetRect)
        var result:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        return result
    }
    
    func setImageToMap(grayArray:UnsafeMutablePointer<UInt8>){
        var _image:UIImage = CVWrapper.createUIImageWithArray(grayArray)
        UIGraphicsBeginImageContext(self.map_image.frame.size);
        _image.drawInRect(CGRect(x: 0,y: 0,width: self.map_image.frame.size.width,height: self.map_image.frame.size.height))
        var scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.map_image.image = scaledImage
    }
    func onSocket(sock: AsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
           //println("--->data length is \(data.length)")
           if data.length > 50{
            if self.last_loc == 0{
                data.getBytes(temp_x, range: NSRange(location: 0, length: 4)) // int x
                data.getBytes(temp_y, range: NSRange(location: 4, length: 4)) // int y
                data.getBytes(temp_t, range: NSRange(location: 8, length: 4)) // int theta
                data.getBytes(temp_map, range:NSRange(location: 12, length: data.length-12)) //map data
                self.last_loc = data.length - 12
//                println("--->x is \(temp_x.memory)")
//                println("--->y is \(temp_y.memory)")
//                println("--->theta is \(temp_t.memory)")
                //consoleOutput("--->x is \(temp_x.memory)--->y is \(temp_y.memory)--->theta is \(temp_t.memory)")
            }else{
                data.getBytes(temp_map+self.last_loc, length: data.length)
                self.last_loc += data.length
                //println("--->map data: is \(temp_map.memory)")
            }
            println("Have reveived \(self.last_loc) ")
            if self.last_loc >= 160000{
                var xx:Float = Float(temp_x.memory)
                var yy:Float = Float(temp_y.memory)
                var ratio = Float(self.map_image.bounds.height/3000)
                receive_time++
                consoleOutput("Map data receive finished!--->\(receive_time)")
                self.last_loc = 0
                temp_point.x = CGFloat(xx*ratio)
                temp_point.y = CGFloat(yy*ratio)
                self.setImageToMap(temp_map)
                self.RobotGoTo(temp_point)
                testtest()
                var info:String = "5"
                self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
            }
           }else{
             //println(NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
            consoleOutput( NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
        }
       //consoleOutput( NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
        sock.readDataWithTimeout(-1, tag: 0)
    }

}

