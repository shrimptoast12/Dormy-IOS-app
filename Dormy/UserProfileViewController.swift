//
//  UserProfileViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var roommateName: String? = ""
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textF: UITextView!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var roomNumber: UILabel!
    @IBOutlet weak var availLabel: UILabel!
    @IBOutlet weak var availSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptView: UITextView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBAction func availSwitched(sender: AnyObject) {
        if (availSwitch.on) {
            self.availLabel.text = "Available"
            self.availLabel.textColor = AppDelegate().RGB(58.0, g: 165.0, b: 63.0)
        }
        else {
            self.availLabel.text = "Unavailable"
            self.availLabel.textColor = AppDelegate().RGB(227.0, g: 43.0, b: 35.0)
        }
        let uid = FIRAuth.auth()?.currentUser?.uid
        if (uid != nil) {
            let availability = self.availLabel.text!
            FIRDatabase.database().reference().child("users").child(uid!).child("availability").setValue(availability)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // Set up stuff
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView()
        nameLabel.text = ""
        roomNumber.text = ""
        self.tableView.rowHeight = 50
        checkUser()
        // set some delegates
        textF.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Set UI elements
        self.descriptView.layer.borderWidth = 1
        self.descriptView.layer.borderColor = AppDelegate().RGB(80.0, g: 186.0, b: 99.0).CGColor
        self.descriptView.layer.cornerRadius = 5
        
        //Round the profile picture
        self.profPic.layer.borderWidth = 3.0
        self.profPic.layer.masksToBounds = false
        self.profPic.layer.borderColor = UIColor.whiteColor().CGColor
        self.profPic.layer.cornerRadius = self.profPic.frame.size.width/2
        self.profPic.clipsToBounds = true

        self.navBar.titleTextAttributes = [NSForegroundColorAttributeName: AppDelegate().RGB(80.0, g: 186.0, b: 99.0)]
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

                    if dictionary["roommate"] != nil {
                        self.roommateName = (dictionary["roommate"] as? String)!
                        self.tableView.reloadData()
                    }
                    let roomNumber = dictionary["roomNumber"] as? String
                    if roomNumber != nil && roomNumber != "" {
                        self.roomNumber.text = "Room \(roomNumber!)"
                    }
                    else {
                        self.roomNumber.text = "no room number"
                    }
                    
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
                                self.tableView.reloadData()
                            })
                        }).resume()
                    }
                    // If the user is an RA, let the user profile show availability
                    let raFlag = dictionary["RA"] as? String
                    self.availSwitch.hidden = true
                    self.availLabel.hidden = true
                    if (raFlag == "true") {
                        // display the avaibility switch and label
                        self.availSwitch.hidden = false
                        self.availLabel.hidden = false
                        
                        // grab the RA's availibity and set the switch/label accordingly
                        let availability = dictionary["availability"] as? String
                        if (availability != "")
                        {
                            self.availLabel.text = availability
                            if (availability == "Available")
                            {
                                self.availSwitch.on = true
                            }
                            else {
                                self.availSwitch.on = false
                                self.availLabel.text = "Unavailable"
                                self.availLabel.textColor = AppDelegate().RGB(227.0, g: 43.0, b: 35.0)

                            }
                        }
                    }
                }
                
                }, withCancelBlock: nil)
        }
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
            let storageRef = FIRStorage.storage().reference().child("profilePictures").child("\(uniqueImageName).jpg")
            
            //Compression factor of 0.1 on User images
            if let profileImage = self.profPic.image, uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
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
    
    // unwind seque for cancel description
    @IBAction func unwindFromDescript(sender: UIStoryboardSegue) {}
    

    @IBAction func moreButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let bulletin = UIAlertAction(title: "Bulletin Board", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // This will eventually segue to the bulletin board
        })
        let edit = UIAlertAction(title: "Edit Profile", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            //I would like to change this so the animation doesn't go up and down
            //It detaches from the status bar and it cuts the block of color in half -Ben
            let editView = self.storyboard?.instantiateViewControllerWithIdentifier("EditDescription") as! EditDescriptionViewController
            editView.vc = self
            self.presentViewController(editView, animated: true, completion: nil)
        })
        let logout = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            try! FIRAuth.auth()?.signOut()
            let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("login") as! ViewController
            self.presentViewController(loginViewController, animated: true, completion: nil)

        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            //exit action sheet
        })
        
        alertController.addAction(bulletin)
        alertController.addAction(edit)
        alertController.addAction(logout)
        alertController.addAction(cancel)

        
        presentViewController(alertController, animated: true, completion: nil)

    }
    
    // TableView Protocol methods for showing the list of roommates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        if roommateName != "" {
            let cell:UserCell = self.tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! UserCell
            cell.profileImageView.image = UIImage(named: "empty_profile")
            cell.textLabel?.text = roommateName
            return cell
        }
        else {
            let cell:UserCell = self.tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! UserCell
            cell.profileImageView.image = UIImage(named: "empty_profile")
            cell.textLabel!.text = "no roomates..."
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    
}
