//
//  OtherProfileViewController.swift
//  Dormy
//
//  Created by Tran, Viet Q on 11/20/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class OtherProfileViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var currentUser = User()
    @IBOutlet weak var coloredProfileView: UIView!
    @IBOutlet weak var textF: UITextView!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var roomNumber: UILabel!
    @IBOutlet weak var availLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptView: UITextView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    func setUpNavBarColor() {
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img,forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barTintColor = AppDelegate().RGB(240.0,g: 208.0,b: 138.0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up stuff
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView()
        roomNumber.text = ""
        self.tableView.rowHeight = 55
        getUser()
        // set some delegates
        textF.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Set UI elements
        self.descriptView.layer.borderWidth = 1
        self.descriptView.layer.borderColor = AppDelegate().RGB(80.0, g: 186.0, b: 99.0).CGColor
        self.descriptView.layer.cornerRadius = 5
        
        //Round the profile picture
        self.coloredProfileView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        self.coloredProfileView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        self.coloredProfileView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        self.coloredProfileView.heightAnchor.constraintEqualToConstant(154)
        self.profPic.layer.borderWidth = 3.0
        self.profPic.layer.masksToBounds = false
        self.profPic.layer.borderColor = UIColor.whiteColor().CGColor
        self.profPic.layer.cornerRadius = self.profPic.frame.size.width/2
        self.profPic.clipsToBounds = true
        
        self.setUpNavBarColor()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUser() {
        let user = currentUser
        self.navigationItem.title = user.name
        FIRDatabase.database().reference().child("users").child(user.id!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //Save the roommate id's into an array
                if let roommates = dictionary["roommates"] as? NSDictionary {
                    for (_,value) in roommates {
                        let id = (value["roommateId"] as! String)
                        self.currentUser.roommatesIdList.append(id)
                    }
                }
                self.tableView.reloadData()
                
                let roomNumber = dictionary["roomNumber"] as? String
                if roomNumber != nil && roomNumber != "" {
                    self.roomNumber.text = "Room \(roomNumber!)"
                }
                else {
                    self.roomNumber.text = "no room number"
                }
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
                let raFlag = dictionary["RA"] as? String
                self.availLabel.hidden = true
                if (raFlag == "true") {
                    // display the avaibility switch and label
                    self.availLabel.hidden = false
                    // grab the RA's availibity and set the switch/label accordingly
                    let availability = dictionary["availability"] as? String
                    if (availability != "")
                    {
                        if (availability == "Available")
                        {
                            self.availLabel.text = availability
                        }
                        else {
                            self.availLabel.text = "Unavailable"
                            self.availLabel.textColor = AppDelegate().RGB(227.0, g: 43.0, b: 35.0)
                        }
                    }
                }
                self.textF.text = dictionary["descript"] as? String
            }
            }, withCancelBlock: nil)
        
    }
    
     
    // restrict the amount of characters in the text view
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxChar: Int = 432
        return textView.text.characters.count + (text.characters.count - range.length) <= maxChar
    }
    
    // TableView Protocol methods for showing the list of roommates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.currentUser.roommatesIdList.count > 0 {
            return self.currentUser.roommatesIdList.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        let cell:UserCell = self.tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! UserCell
        
        if self.currentUser.roommatesIdList.isEmpty {
            cell.profileImageView.image = UIImage(named: "empty_profile")
            cell.textLabel!.text = "no roomates..."
        }
        else { //Load the roommates into the tableview
            let roommateId = self.currentUser.roommatesIdList[indexPath.row]
            let ref = FIRDatabase.database().reference().child("users").child(roommateId)
            ref.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    cell.textLabel!.text = dictionary["name"] as? String
                    
                    if (dictionary["imageURL"] as! String == "" ) {
                        cell.profileImageView.image = UIImage(named: "empty_profile")
                    }
                    else {
                        cell.profileImageView.loadImageUsingCacheWithUrlString(dictionary["imageURL"] as! String)
                    }
                }}, withCancelBlock: nil)
        }
        return cell
    }
    
    // function that lets user view a roommates profile
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (!self.currentUser.roommatesIdList.isEmpty) {
            let otherProf = self.storyboard?.instantiateViewControllerWithIdentifier("OtherProfile") as! OtherProfileViewController
            let navController = UINavigationController(rootViewController: otherProf)
            let otherUserID = self.currentUser.roommatesIdList[indexPath.row]
            let ref = FIRDatabase.database().reference().child("users").child(otherUserID)
            let selectedUser = User()
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    selectedUser.setUserWithDictionary(dictionary, uid: otherUserID)
                    otherProf.currentUser = selectedUser
                    self.presentViewController(navController, animated: true, completion: nil)
                }
            }, withCancelBlock: nil)
        }
    }
}
