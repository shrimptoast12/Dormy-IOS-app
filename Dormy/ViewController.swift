//
//  ViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.navigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Button rounding and various UI setting
        signUp.backgroundColor = UIColor.clearColor()
        signUp.layer.cornerRadius = 5
        signUp.layer.borderWidth = 1
        signUp.layer.borderColor = UIColor.blackColor().CGColor
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.clearColor().CGColor
        
        if (FIRAuth.auth()?.currentUser) != nil {
            //The user has logged in already, skip the sign in page and go to their profile
            let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("profile") as! UserProfileViewController
            self.presentViewController(profileViewController, animated: true, completion: nil)
        }
        
        // set text field delegates to dismiss keyboard on return
        emailField.delegate = self
        passwordField.delegate = self
    }
    // This lets the cancel slide left and right, not up and down
    // Currently causes a bug in which the current user doesn't log out
    //@IBAction func unwindFromRegister(sender: UIStoryboardSegue) {}
    
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
                    let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("profile") as! UserProfileViewController
                    self.presentViewController(profileViewController, animated: true, completion: nil)
                    
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
}

