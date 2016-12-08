//
//  AlertViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class AlertViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleOfPost: UITextField!
    @IBOutlet weak var post: UITextView!
    
    // Saves the alert post after you press done
    @IBAction func doneAction(sender: AnyObject) {
        if(titleOfPost.text != "" || post.text != "") {
            let ref = FIRDatabase.database().reference().child("bulletin")
            let child = ref.childByAutoId()
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
                    let values: [String: AnyObject] = ["owner": (dictionary["name"] as? String)!,
                        "profileImage": (dictionary["imageURL"] as? String)!,
                        "description": self.post.text,
                        "startDate": "",
                        "endDate": "",
                        "image": "",
                        "timeStamp": timeStamp,
                        "postType": "alert",
                        "title": self.titleOfPost.text!]
                    
                    child.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            print(err)
                            return
                        }
                    })
                    //Post successful, Segue back to the main Bulletin Page
                    self.segueToBulletinWithSWReveal()
                }
                }, withCancelBlock: nil)
        }
        else {
            // Warn the user one of the fields is missing
            let alertController = UIAlertController(title: "Oops!", message: "Please enter a title or description!", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func segueToBulletinWithSWReveal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sw = storyboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        self.view.window?.rootViewController = sw
        let bulletin = self.storyboard?.instantiateViewControllerWithIdentifier("Bulletin") as! BulletinBoardTableViewController
        let navController = UINavigationController(rootViewController: bulletin)
        sw.pushFrontViewController(navController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.tapHandler(_:)))
        view.addGestureRecognizer(tapRecognizer)
        
        // Do any additional setup after loading the view.
        titleOfPost.delegate = self
        post.delegate = self
        
        //Setting up textView UI
        self.post.layer.borderWidth = 1
        self.post.layer.borderColor = AppDelegate().RGB(80.0, g: 186.0, b: 99.0).CGColor
        self.post.layer.cornerRadius = 5

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // functions below this helps deal with the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        titleOfPost.resignFirstResponder()
        return true
    }
    
    func tapHandler(gesture: UITapGestureRecognizer){
        titleOfPost.resignFirstResponder()
        post.resignFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxChar: Int = 432
        return textView.text.characters.count + (text.characters.count - range.length) <= maxChar
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "alertPreview"){
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            FIRDatabase.database().reference().child("users").child(uid!).observeEventType(.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let eventPost = Post()
                    let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
                    let values: [String: AnyObject] = ["owner": dictionary["name"]!,
                        "profileImage": dictionary["imageURL"]!,
                        "description": self.post.text,
                        "startDate": "",
                        "endDate": "",
                        "image": "",
                        "timeStamp": timeStamp,
                        "postType": "alert",
                        "title": self.titleOfPost.text!]
                    eventPost.setPostWithDictionary(values, postId: "")
                    let destination = segue.destinationViewController as? PreviewTableViewController
                    destination!.post = eventPost
                }
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                }, withCancelBlock: nil)
        }
    }

}
