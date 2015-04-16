//
//  ViewController.swift
//  carService2
//
//  Created by 杨培文 on 15/3/27.
//  Copyright (c) 2015年 杨培文. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate=self
        locationManager.requestAlwaysAuthorization()
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates()
            println("开始方向检测")
        }else {
            UIAlertView(title: "提示", message: "不支持方向的设备", delegate: nil, cancelButtonTitle: "确定").show()
            println("不支持方向的设备")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func out(str:String){
        label.text = str
        println(str)
    }
    
    var client = TCPClient(addr: "192.168.1.1", port: 8899)
    
    @IBOutlet weak var label: UILabel!
    @IBAction func click(sender: AnyObject) {
        out("连接中")
        var (success,error) = client.connect(timeout: 10)
        if !success{
            out(error)
        }else{
            out("连接成功,开始读取数据")
            xiancheng({
                self.readThread()
            })
        }
    }
    
    class mypoint{
        var x:Double = 0.0
        var y:Double = 0.0
        init(xx:Double, yy:Double){
            x=xx;
            y=yy;
        }
        func add(deltax:Double, deltay:Double){
            x += deltax;
            y += deltay;
        }
        func toString()->String{
            return "x=\(x)\ny=\(y)"
        }
    }
    
    var position = mypoint(xx: 0, yy: 0)
    
    @IBOutlet weak var positionlabel: UILabel!
    
    func readThread(){
        while true{
            var rec = read()
            ui({
                self.label.text = rec
                var rec2 = rec as NSString
                let indexr = rec2.rangeOfString("\r").location
                if  indexr != 9223372036854775807{
                    rec = rec2.substringToIndex(indexr)
                    var add = rec.toInt()
                    //                rec = rec.stringByReplacingOccurrencesOfString("\n", withString: "")
                    //                rec = rec.stringByReplacingOccurrencesOfString("\r", withString: "")
                    //                var add = rec.toInt()
                    
                    if let d = self.motionManager.deviceMotion.attitude{
                        var yaw = d.yaw
                        if add != nil {
                            var xx = -sin(yaw)*Double(add!)
                            var yy = cos(yaw)*Double(add!)
                            self.position.add(xx, deltay: yy)
                            self.positionlabel.text = self.position.toString()
                        }
                        else{
                            println("[\(rec)]")
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func sendCMD(sender: AnyObject) {
//        if let cmd = (sender as UIButton).titleLabel?.text{
//            send(cmd)
//        }
        send(" ")
        println("up")
    }
    
    
    @IBAction func down(sender: AnyObject) {
        if let cmd = (sender as UIButton).titleLabel?.text{
            send(cmd)
        }
        println("down")
    }
    
    
    func read()->String{
        var asdsa = ""
        if let re = client.read(1024*10){
            if let str = byteToString(re){
                asdsa = str
            }
            println("获取数据成功:\(asdsa)")
        }
        return asdsa
    }
    
    func send(str:String){
        println("开始发送数据:\(str)")
        let (succeed,error) = client.send(data: str.dataUsingEncoding(NSUTF8StringEncoding)!)
        if succeed{
            println("发送数据成功")
        }else{
            println("发送数据失败:\(error)")
        }
    }
    
    func byteToString(buf:[Byte])->String?{
        return NSString(bytes: buf, length: buf.count, encoding: NSUTF8StringEncoding)
    }
    
    func xiancheng(code:dispatch_block_t){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), code)
    }
    func ui(code:dispatch_block_t){
        dispatch_async(dispatch_get_main_queue(), code)
    }

}

