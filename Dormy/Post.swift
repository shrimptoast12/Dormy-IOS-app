//
//  Post.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class Post {
    
    var description: String?
    var endDate: String?
    var image: String?
    var owner: String?
    var postType: String?
    var profileImage: String?
    var startDate: String?
    var timeStamp: NSNumber?
    var title: String?
    
    func setPostWithDictionary(dict: [String: AnyObject]) {
        description = dict["description"] as? String
        endDate = dict["endDate"] as? String
        image = dict["image"] as? String
        owner = dict["owner"] as? String
        postType = dict["postType"] as? String
        profileImage = dict["profileImage"] as? String
        startDate = dict["startDate"] as? String
        timeStamp = dict["timeStamp"] as? NSNumber
        title = dict["title"] as? String
    }
}