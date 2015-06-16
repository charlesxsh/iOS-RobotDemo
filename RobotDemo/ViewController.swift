//
//  ViewController.swift
//  RobotDemo
//
//  Created by Charles Xia on 5/29/15.
//  Copyright (c) 2015 Charles. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController,AsyncSocketDelegate,UIGestureRecognizerDelegate{
    @IBOutlet weak var map: MapUIView!
    @IBOutlet weak var robot: UIView!
    @IBOutlet weak var console: UITextView!
    @IBOutlet weak var hostTextfield: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var portTextfield: UITextField!
    @IBOutlet weak var streamInput: UITextField!
    var temp_img:UIImage = UIImage()
    var socket:AsyncSocket = AsyncSocket()
    var image_data:CVWrapper = CVWrapper()
    var last_loc:Int = 0
    
    var temp_map:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(90000)
    var temp_x:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var temp_y:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    var temp_t:UnsafeMutablePointer<Int32> = UnsafeMutablePointer<Int32>.alloc(1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostTextfield.text = "10.0.0.40"
        self.portTextfield.text = "8000"
        self.streamInput.text = "3"
        var gst = UITapGestureRecognizer(target: self, action:Selector("handleSingleTap:"))
        self.map.addGestureRecognizer(gst)
        gst.delegate = self
        socket.setDelegate(self)
        self.image.contentMode = UIViewContentMode.ScaleToFill
        self.image.image = image_data.toUIImage()
            }
    @IBAction func snedToServer(sender: AnyObject) {
        var info:String = streamInput.text
        self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
        consoleOutput("Sent:\(info)")
    }
    func rotateRobot(p:CGPoint){
        var y:CGFloat = p.y - self.robot.center.y
        var x:CGFloat = p.x - self.robot.center.x
        if(x > 0){
            self.robot.transform =  CGAffineTransformMakeRotation(CGFloat(M_PI/2) + atan(y/x))
        }else{
            self.robot.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) + (CGFloat(M_PI/2) - atan(y/(-x))))
        }
    }

    
    @IBAction func handleSingleTap(recognizer:UITapGestureRecognizer){
        var p:CGPoint = recognizer.locationInView(self.map)
//        var a = UIAlertController(title: "Info", message: "Point is x:\(p.x) y:\(p.y)", preferredStyle: UIAlertControllerStyle.Alert)
//        let confirm = UIAlertAction(title: "Confirm", style: .Cancel, handler: nil)
//        a.addAction(confirm)
//        self.presentViewController(a, animated: true, completion: nil)
        UIView.animateWithDuration(3, animations: { () -> Void in
            self.rotateRobot(p)
        })
        UIView.animateWithDuration(3, delay: 3, options: nil, animations: { () -> Void in
                        self.robot.center = p
        }, completion: nil)
        consoleOutput(PositionInfo(self.robot.center))
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
   
//    @IBAction func printinfo(sender: AnyObject) {
//        var tempraw = [Int](count: 300, repeatedValue: 200)
//        var tempdata = [[Int]](count: 300, repeatedValue: tempraw)
      //self.map.updateView(self.robot.center, ti: createImagewithArray(tempdata))
//    }
    
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
    
    func createImagewithArray(grayArray:UnsafeMutablePointer<UInt8>)->UIImage{
        var origImage:UIImage = CVWrapper.createUIImageWithArray(grayArray)
        var ratio = self.map.bounds.size.width / 3000
        var length = 300 * ratio
        var targetRect = CGRect(x: 0, y: 0, width: length, height: length)
        UIGraphicsBeginImageContext(CGSize(width: length, height: length))
        origImage.drawInRect(targetRect)
        var result:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        return result
    }
    
    func parseDataToArray(data:NSData)->[AnyObject]{
        var string:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        var result = string.componentsSeparatedByString(" ")
        return result
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
                consoleOutput("--->x is \(temp_x.memory)--->y is \(temp_y.memory)--->theta is \(temp_t.memory)")
            }else{
                data.getBytes(temp_map+self.last_loc, length: data.length)
                self.last_loc += data.length
                println("--->map data: is \(temp_map.memory)")
            }
            println("Have reveived \(self.last_loc) ")
            if self.last_loc == 90000{
                var xx:Float = Float(temp_x.memory)
                var yy:Float = Float(temp_y.memory)
                var ratio = Float(self.map.bounds.height/3000)
                println("Map data receive finished!")
                self.last_loc = 0
                var info:String = "5"
                self.socket.writeData(info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: -1, tag: 0)
                temp_img = self.createImagewithArray(temp_map)
                var p:CGPoint = CGPoint(x: CGFloat(xx*ratio), y: CGFloat(yy*ratio))
                UIView.animateWithDuration(1, delay: 0, options: nil, animations: { () -> Void in
                    self.robot.center = p
                    }, completion: nil)
                self.map.updateView(self.robot.center, ti: temp_img)
                println("---------------------------------------")
            }

           }else{
             //println(NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
            consoleOutput( NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
        }
       //consoleOutput( NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
        sock.readDataWithTimeout(-1, tag: 0)
    }

}

