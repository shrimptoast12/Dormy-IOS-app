//
//  WriteCommentViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/7/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class WriteCommentViewController: UIViewController {
    
    @IBOutlet weak var writePost: UITextView!
    var post = Post()
    var nested = false
    var commentId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up textView UI
        self.writePost.layer.borderWidth = 1
        self.writePost.layer.borderColor = AppDelegate().RGB(80.0, g: 186.0, b: 99.0).CGColor
        self.writePost.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func makeNestedComment() {
        let ref = FIRDatabase.database().reference().child("bulletin").child(self.post.postId!).child("comments").child(commentId).child("nested")
        let child = ref.childByAutoId()
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                
                let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
                let comment: [String: AnyObject] = ["comment": self.writePost.text,
                    "user": (dictionary["name"] as? String)!,
                    "profileImage": (dictionary["imageURL"] as? String)!,
                    "timeStamp": timeStamp]
                
                child.updateChildValues(comment, withCompletionBlock: { (err, ref) in
                    if(err != nil) {
                        print(err)
                        return
                    }
                })
                // succesfully added comment
            }
            }, withCancelBlock: nil)

    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //Add comment to Firebase
        if (self.nested) {
            makeNestedComment()
        } else {
        
            let ref = FIRDatabase.database().reference().child("bulletin").child(self.post.postId!).child("comments")
            let child = ref.childByAutoId()
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                
                    
                        let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
                        let comment: [String: AnyObject] = ["comment": self.writePost.text,
                            "user": (dictionary["name"] as? String)!,
                            "profileImage": (dictionary["imageURL"] as? String)!,
                            "timeStamp": timeStamp]
                    
                        child.updateChildValues(comment, withCompletionBlock: { (err, ref) in
                            if(err != nil) {
                                print(err)
                                return
                            }
                        })
                        // succesfully added comment
                }
                }, withCancelBlock: nil)
        }
        if (segue.identifier == "postComment") {
            let destination = segue.destinationViewController as? BulletinThreadTableViewController
            destination?.post = self.post
        }

    print("Prepare for segue")
    }
    
    
}