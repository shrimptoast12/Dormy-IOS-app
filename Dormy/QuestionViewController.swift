//
//  QuestionViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class QuestionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate  {

    @IBOutlet weak var titleOfPost: UITextField!
    @IBOutlet weak var post: UITextView!
    // Posts the question the user just entered
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
                        "postType": "question",
                        "title": self.titleOfPost.text!]
                    
                    child.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            print(err)
                            return
                        }
                    })
                    let bulletin = self.storyboard?.instantiateViewControllerWithIdentifier("Bulletin") as! BulletinBoardTableViewController
                    let navController = UINavigationController(rootViewController: bulletin)
                    self.presentViewController(navController, animated: true, completion: nil)
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
    
    // hides keyboard after hitting return
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        titleOfPost.resignFirstResponder()
        return true
    }
    
    // helps with handling the keyboard
    func tapHandler(gesture: UITapGestureRecognizer){
        titleOfPost.resignFirstResponder()
        post.resignFirstResponder()
    }
    
    // limits the amount of characters you can use for the post
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxChar: Int = 432
        return textView.text.characters.count + (text.characters.count - range.length) <= maxChar
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
