//
//  User.swift
//  Dormy
//
//  Created by Benjamin Lee on 11/2/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
    var RA:String?
    var availability:String? 
    var descript:String?
    var email:String?
    var imageURL: String?
    var name:String?
    var roomNumber:String?
    var roommatesIdList = [String]()
    var id:String?
    
    func setUserWithDictionary(dictionary:NSDictionary, uid:String) {
        RA = dictionary["RA"] as? String
        availability = dictionary["availability"] as? String
        descript = dictionary["descript"] as? String
        email = dictionary["email"] as? String
        imageURL = dictionary["imageURL"] as? String
        name = dictionary["name"] as? String
        roomNumber = dictionary["roomNumber"] as? String
   }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
//        lhs.RA == rhs.RA &&
//        lhs.availability == rhs.availability &&
//        lhs.descript == rhs.descript &&
//        lhs.email == rhs.email &&
//        lhs.imageURL == rhs.imageURL &&
//        lhs.RA == rhs.RA &&
//        lhs.RA == rhs.RA
}
