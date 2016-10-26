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
    
    // Helper function to generate a UIColor based on RBG values. Arguments must be of type CGFloat
    func RGB(r:CGFloat, g:CGFloat, b:CGFloat) ->UIColor {
        return UIColor(red: r / 255.0, green: g / 255.0 , blue: b / 255.0 ,alpha: 1.0)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.navigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (FIRAuth.auth()?.currentUser) != nil {
            //The user has logged in already, skip the sign in page and go to their profile
            let profileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("profile") as! UserProfileViewController
            self.presentViewController(profileViewController, animated: true, completion: nil)

        }
        else {
            self.logoutButton.alpha = 0.0
            self.usernameLabel.text = "Dormy"
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
    
//    @IBAction func logoutAction(sender: AnyObject) {
//        try! FIRAuth.auth()?.signOut()
//        self.usernameLabel.text = ""
//        self.emailField.text = ""
//        self.passwordField.text = ""
//        self.logoutButton.alpha = 0.0
//    }
}

