//
//  SettingsViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 11/22/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var currentName: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var soundSwitch: UISwitch!
    
    @IBAction func notifcationAction(sender: AnyObject) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        var notificationOn = true
        if (notificationSwitch.on) {
            notificationOn = true
        }
        else {
            notificationOn = false
        }
        if (uid != nil) {
            FIRDatabase.database().reference().child("settings").child(uid!).child("notifications").setValue(notificationOn)
        }
    }
    @IBAction func soundAction(sender: AnyObject) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        var soundOn = true
        if (soundSwitch.on) {
            soundOn = true
        }
        else {
            soundOn = false
        }
        if (uid != nil) {
            FIRDatabase.database().reference().child("settings").child(uid!).child("sound").setValue(soundOn)
        }
    }
    // Function that changes the current user's name after he does so in settings
    @IBAction func changeName(sender: AnyObject) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("users").child(uid!)
        let name = enterName.text!
        ref.child("name").setValue(name)
        currentName.text = enterName.text!
        enterName.text = ""
    }
    @IBOutlet weak var enterName: UITextField!
    func setUpNavBarColor() {
        let nav = self.navigationController?.navigationBar
        nav?.translucent = false
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img,forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barTintColor = AppDelegate().RGB(240.0,g: 208.0,b: 138.0)
        self.navigationController?.navigationBar.tintColor = AppDelegate().RGB(68.0, g: 176.0,b:80.0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBarColor()
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("users").child(uid!)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                if let name = dictionary["name"] as? String {
                    self.currentName.text = name
                }
            }
            }, withCancelBlock: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.tapHandler(_:)))
        view.addGestureRecognizer(tapRecognizer)
        enterName.delegate = self
        
        // Set the switches to their correct boolean value in settings
        FIRDatabase.database().reference().child("settings").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.notificationSwitch.on = (dictionary["notifications"] as? Bool)!
                self.soundSwitch.on = (dictionary["sound"] as? Bool)!
            }
            }, withCancelBlock: nil)
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        enterName.resignFirstResponder()
        return true
    }
    
    func tapHandler(gesture: UITapGestureRecognizer){
        enterName.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 150)
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 150)
    }
    
    // function used to move the text field up so keyboard doesn't cover it
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
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
