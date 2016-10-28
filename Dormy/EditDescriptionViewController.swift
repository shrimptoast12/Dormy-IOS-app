//
//  EditDescriptionViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class EditDescriptionViewController: UIViewController, UITextViewDelegate {
    
    weak var vc:UserProfileViewController?

    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var roomateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTextView.text = vc!.textF.text
        let roomNum = vc!.roomNumber.text!
        if roomNum == "no room number" {
            roomNumberTextField.text = ""
        }
        else {
            //Trims the "Room " out of "Room <number>"
            roomNumberTextField.text = String(roomNum.characters.dropFirst(5))
        }
        let roommateName = vc!.roommateName
        if roommateName != "" {
            self.roomateTextField.text = roommateName
        }
        
        myTextView.delegate = self
        
        // Give the text view a border
        self.myTextView.layer.borderWidth = 1
        self.myTextView.layer.borderColor = AppDelegate().RGB(80.0, g: 186.0, b: 99.0).CGColor
        self.myTextView.layer.cornerRadius = 5
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
            let roommate = self.roomateTextField.text!
            
            FIRDatabase.database().reference().child("users").child(uid!).child("descript").setValue(descript)
            FIRDatabase.database().reference().child("users").child(uid!).child("roomNumber").setValue(roomNumber)
            FIRDatabase.database().reference().child("users").child(uid!).child("roommate").setValue(roommate)
        }
        
        let profVC = storyboard?.instantiateViewControllerWithIdentifier("profile") as! UserProfileViewController
        self.presentViewController(profVC, animated: true, completion: nil)
    }

    // Makes the keyboard go away when you touch anywhere outside the text field or keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
