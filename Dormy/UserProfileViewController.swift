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
    @IBOutlet weak var profPic: UIImageView!
    
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
            // grabs data from Firebase Database and loads up the user profile
            let user = FIRAuth.auth()?.currentUser
            let uid = user?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.nameLabel.text = dictionary["name"] as? String
                    self.textF.text = dictionary["descript"] as? String
                    
                    // loads the profile picture of the user from storage using the imageURL from database
                    if let imageURL = dictionary["imageURL"] as? String {
                        let url = NSURL(string: imageURL)
                        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                            if (error != nil) {
                                print(error)
                                return
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                self.profPic?.image = UIImage(data: data!)
                            })
                        }).resume()
                    }
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
        imagePicker.allowsEditing = true
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // function that brings up the camera roll and lets user choose a picture
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImage:UIImage?
        
        // Let user edit an image
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginlImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        let uniqueImageName = NSUUID().UUIDString // create a unique string ID for every picture to upload to database
        // load the picture onto Firebase Storage
        if let profilePic = selectedImage {
            profPic.image = profilePic
            let storageRef = FIRStorage.storage().reference().child("profilePictures").child("\(uniqueImageName).png")
            if let uploadData = UIImagePNGRepresentation(self.profPic.image!) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    // Set the imageURL for a user inside Firebase Database
                    let uid = FIRAuth.auth()?.currentUser?.uid
                    
                    if (uid != nil) {
                        let imageURL = metadata?.downloadURL()?.absoluteString
                        FIRDatabase.database().reference().child("users").child(uid!).child("imageURL").setValue(imageURL)
                    }
                })
            }
        }
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
