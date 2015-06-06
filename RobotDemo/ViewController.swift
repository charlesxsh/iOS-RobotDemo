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
    var socket:AsyncSocket = AsyncSocket()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostTextfield.text = "10.0.0.40"
        self.portTextfield.text = "8000"
        self.streamInput.text = "3"
        var gst = UITapGestureRecognizer(target: self, action:Selector("handleSingleTap:"))
        self.map.addGestureRecognizer(gst)
        gst.delegate = self
        socket.setDelegate(self)
        //self.image.image = CVWrapper.createUIImageWithArray(nil)
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
    @IBAction func rightRotation(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: { () -> Void in
                self.robot.transform = CGAffineTransformRotate(self.robot.transform,CGFloat(10*(M_PI/180)))
        })
        
    }
    @IBAction func leftRotation(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.robot.transform = CGAffineTransformRotate(self.robot.transform, -CGFloat(10*(M_PI/180)))
        })
    }
    @IBAction func printinfo(sender: AnyObject) {
        var tempraw = [Int](count: 300, repeatedValue: 200)
        var tempdata = [[Int]](count: 300, repeatedValue: tempraw)
        self.map.updateView(self.robot.center, ti: createImagewithArray(tempdata))
    }
    
    @IBAction func cleanConsole(sender: AnyObject) {
        self.console.text = ""
    }
    func PositionInfo(p:CGPoint)->String{
        return "x:\(p.x) y:\(p.y)"
    }
    @IBAction func robotup(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.robot.center.y = self.robot.center.y-10
        })
        consoleOutput(PositionInfo(self.robot.center))
    }

    @IBAction func robotright(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.robot.center.x = self.robot.center.x+10
        })
        consoleOutput(PositionInfo(self.robot.center))
    }
    @IBAction func robotdown(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.robot.center.y = self.robot.center.y+10
        })
        consoleOutput(PositionInfo(self.robot.center))
    }
    @IBAction func robotleft(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: { () -> Void in
self.robot.center.x = self.robot.center.x-10
        })
        consoleOutput(PositionInfo(self.robot.center))
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
    
    func createImagewithArray(grayArray:[AnyObject])->UIImage{
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
        print(NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
       consoleOutput( NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
        sock.readDataWithTimeout(-1, tag: 0)
    }

}

