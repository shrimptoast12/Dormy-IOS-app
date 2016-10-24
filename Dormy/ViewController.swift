//
//  ViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = FIRAuth.auth()?.currentUser {
            self.logoutButton.alpha = 1.0
            self.usernameLabel.text = user.email
        }
        else {
            self.logoutButton.alpha = 0.0
            self.usernameLabel.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Makes keyboard go away when you touch Return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hides the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // Makes the keyboard go away when you touch anywhere outside the text field or keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func createAccountAction(sender: AnyObject) {
        //        //if either text fields are empty. print error
        //        if self.emailField.text == "" || self.passwordField.text == "" {
        //            let alertController = UIAlertController(title: "Oops!", message: "Please enter email and password.", preferredStyle: .Alert)
        //            let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        //            alertController.addAction(defaultAction)
        //            self.presentViewController(alertController, animated: true, completion: nil)
        //        }
        //        else {
        //            FIRAuth.auth()?.createUserWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
        //                if error == nil {
        //                    // gets the user's uid
        //                    guard let uid = user?.uid else {
        //                        return
        //                    }
        //
        //                    self.logoutButton.alpha = 1.0
        //                    self.usernameLabel.text = user!.email
        //                    let values = ["email": self.emailField.text!]
        //                    let ref = FIRDatabase.database().referenceFromURL("https://test-login-42da2.firebaseio.com/")
        //                    let userRef = ref.child("users").child(uid)
        //                    userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
        //                        if err != nil {
        //                            print(err)
        //                            return
        //                        }
        //                        // else error doesn't occur and we successfully entered user into database
        //                    })
        //                    self.emailField.text = ""
        //                    self.passwordField.text = ""
        //                }
        //                else {
        //                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .Alert)
        //                    let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        //                    alertController.addAction(defaultAction)
        //                    self.presentViewController(alertController, animated: true, completion: nil)
        //                }
        //            })
        //        }
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        if self.emailField.text == "" || self.passwordField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter email and password.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            FIRAuth.auth()?.signInWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                if error == nil {
                    self.logoutButton.alpha = 1.0
                    self.usernameLabel.text = user!.email
                    self.performSegueWithIdentifier("userSegue", sender: nil)
                    
                }
                else {
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        self.usernameLabel.text = ""
        self.emailField.text = ""
        self.passwordField.text = ""
        self.logoutButton.alpha = 0.0
    }
}

