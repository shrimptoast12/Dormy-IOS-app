//
//  WriteCommentViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/7/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class WriteCommentViewController: UIViewController {
    
    @IBOutlet weak var writePost: UITextView!
    var post = Post()
    
    @IBAction func postComment(sender: AnyObject) {
        //        let postComment = self.storyboard?.instantiateViewControllerWithIdentifier("postThread") as! BulletinThreadTableViewController
        //        let navController = UINavigationController(rootViewController: makeComment)
        //        self.presentViewController(navController, animated: true, completion: nil)
        print(post.owner!)
        
    }
    
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
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "postComment") {
            let destination = segue.destinationViewController as? BulletinThreadTableViewController
            destination?.post = post
        }
    }
    
    
}