//
//  Message.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 11/8/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId = [String]()
    
    func setMsgWithDictionary(dictionary:NSDictionary) {
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        let temp = dictionary["toId"] as? String
        toId = parseId(temp!)
    }
    
    //Parse group Id numbers
    func parseId(groupId: String) -> [String]{
        
        let users = groupId.characters.split{$0 == " "}.map(String.init)
        
        return users
    }
    
    func returnId() -> String? {
        let id:String?
        
        if(fromId ==  FIRAuth.auth()?.currentUser?.uid) {
            var temp: String = ""
            for a in 0 ..< toId.count{
                temp += toId[a]
            }
            id = temp
        }
        else {
            id = fromId
        }
        return id
    }
}