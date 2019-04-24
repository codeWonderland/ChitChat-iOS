//
//  ViewController.swift
//  ChitChat
//
//  Created by Easter, Alice on 4/16/19.
//  Copyright © 2019 Easter, Alice. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        netRequest()
    }
    
    func netRequest() {
        Alamofire.request("https://www.stepoutnyc.com/chitchat?key=c9be0e9b-6265-41c6-9090-fd83f6e4537e&client=shawn.fortin@mymail.champlain.edu").responseJSON { response in
            if let json = response.result.value {
                for entry in json {
                    if let message = Message(entry) {
                        print(message.)
                    }
                }
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
    }

}

