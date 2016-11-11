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
    var timeStamp: String?
    var toId: String?
    
    func returnId() -> String? {
        let id:String?
        
        if(fromId ==  FIRAuth.auth()?.currentUser?.uid) {
            id = toId
        }
        else {
            id = fromId
        }
        return id
    }
}