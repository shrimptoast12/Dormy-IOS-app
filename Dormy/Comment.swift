//
//  Comment.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/7/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import Foundation

class Comment {
    
    var comment: String?
    var user: String?
    var profileImage: String?
    var timeStamp: NSNumber?
    var commentType: Bool?
    var commentId: String?
    
    func setCommentWithDictionary(dict: [String: AnyObject], commentId: String, type: Bool){
        
        comment = dict["comment"] as? String
        user = dict["user"] as? String
        profileImage = dict["profileImage"] as? String
        timeStamp = dict["timeStamp"] as? NSNumber
        commentType = type
        self.commentId = commentId
    }
}
