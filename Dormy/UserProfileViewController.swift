//
//  UserProfileViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textF: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        checkUser()
        textF.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkUser() {
        
        // signs out incorrect user
        if (FIRAuth.auth()?.currentUser?.uid == nil) {
            do {
                try FIRAuth.auth()?.signOut()
            } catch let logoutError {
                print(logoutError)
            }
        }
        else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.nameLabel.text = dictionary["name"] as? String
                    self.textF.text = dictionary["descript"] as? String
                }
                
                }, withCancelBlock: nil)
        }
    }
    
    // Allows user to edit their description
    @IBAction func editDescription(sender: AnyObject) {
        let editView = self.storyboard?.instantiateViewControllerWithIdentifier("EditDescription") as! EditDescriptionViewController
        editView.vc = self
        self.presentViewController(editView, animated: true, completion: nil)
    }
    
    // Allows user to upload a profile picture
    @IBAction func uploadImage(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // restrict the amount of characters in the text view
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
