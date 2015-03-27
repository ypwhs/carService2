//
//  ViewController.swift
//  carService2
//
//  Created by 杨培文 on 15/3/27.
//  Copyright (c) 2015年 杨培文. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func out(str:String){
        label.text = str
        println(str)
    }
    
    var client = TCPClient(addr: "10.10.100.254", port: 8899)
    
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
    
    func readThread(){
        while true{
            var rec = read()
            ui({
                self.label.text = rec
            })
        }
    }
    
    @IBAction func sendCMD(sender: AnyObject) {
        if let cmd = (sender as UIButton).titleLabel?.text{
            send(cmd)
        }
    }
    
    
    func read()->String{
        var asdsa = ""
        if let re = client.read(1024*10){
            if let str = byteToString(re){
                asdsa = str
            }else{
                asdsa = t(re)
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
    
    func t(buf:[Byte])->String{
        var re = ""
        for b in buf{
            re+=bts(b)+" "
        }
        re+=" 长度:\(buf.count)"
        return re
    }
    
    func bts(b:Byte)->String{
        var table = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        return "\(table[Int(b/16)])\(table[Int(b%16)])"
    }
    
    func byteToString(buf:[Byte])->String?{
        return NSString(bytes: buf, length: buf.count, encoding: NSUTF8StringEncoding)
    }
    
    func show(show:String){
        ui({
            UIAlertView(title: "", message: show, delegate: nil, cancelButtonTitle: "确定").show()
        })
    }
    
    func xiancheng(code:dispatch_block_t){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), code)
    }
    func ui(code:dispatch_block_t){
        dispatch_async(dispatch_get_main_queue(), code)
    }

}

