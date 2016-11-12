//
//  EditDescriptionViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class EditDescriptionViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var users = [User]()

    weak var vc:UserProfileViewController?
    var roommatesIdList = [String]()

    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var roommatesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 55
        tableView.allowsMultipleSelection = true
        
        myTextView.text = vc!.textF.text
        let roomNum = vc!.roomNumber.text!
        if roomNum == "no room number" {
            roomNumberTextField.text = ""
        }
        else {
            //Trims the "Room " out of "Room <number>"
            roomNumberTextField.text = String(roomNum.characters.dropFirst(5))
        }
        
        myTextView.delegate = self
        
        // Give the text view a border
        self.myTextView.layer.borderWidth = 1
        self.myTextView.layer.borderColor = AppDelegate().RGB(80.0, g: 186.0, b: 99.0).CGColor
        self.myTextView.layer.cornerRadius = 5
        fetchUser()
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("unwindFromDescript", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxChar: Int = 432
        return textView.text.characters.count + (text.characters.count - range.length) <= maxChar
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        vc!.textF.text = myTextView.text
        // update the description in the database
        let uid = FIRAuth.auth()?.currentUser?.uid
        if (uid != nil) {
            let descript = self.myTextView.text!
            let roomNumber = self.roomNumberTextField.text!
            
            
            let ref = FIRDatabase.database().reference().child("users").child(uid!).child("roommates")
            ref.removeValue()
            for id in self.roommatesIdList {
                let childRef = ref.childByAutoId()
                childRef.updateChildValues(["roommateId" : id])
            }
            FIRDatabase.database().reference().child("users").child(uid!).child("descript").setValue(descript)
            FIRDatabase.database().reference().child("users").child(uid!).child("roomNumber").setValue(roomNumber)
        }
        
        let profVC = storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        self.presentViewController(profVC, animated: true, completion: nil)
    }

    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                
                user.setUserWithDictionary(dictionary,uid: user.id!)
                //Do not allow the user to add themselves
                if (user.id != self.vc?.currentUser.id) {
                    self.users.append(user)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
            
            }, withCancelBlock: nil)
        
    }


    // Makes the keyboard go away when you touch anywhere outside the text field or keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    // TableView Protocol methods for showing the list of users
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellId", forIndexPath: indexPath) as! UserCell
        cell.selectionStyle = .None
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        
        //Have existing roommates checked in the edit view
        if (self.roommatesIdList.contains(user.id!)) {
            cell.selected = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        if user.imageURL == "" {
            cell.profileImageView.image = UIImage(named: "empty_profile")
        }
        else {
            if let profileImageUrl = user.imageURL {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
        }

        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let roommate = users[indexPath.row]
        if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark){
            cell!.accessoryType = UITableViewCellAccessoryType.None;
            self.roommatesIdList.removeAtIndex(self.roommatesIdList.indexOf(roommate.id!)!)
        }
        else{
            self.roommatesIdList.append(roommate.id!)
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark;
            
        }
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
