//
//  RegisterViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func registerAction(sender: AnyObject) {
        // if either text fields are empty. print error
        if self.emailField.text == "" || self.passwordField.text == "" || self.nicknameField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter email and password.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            // else register the user
            FIRAuth.auth()?.createUserWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                if error == nil {
                    // gets the user's uid
                    guard let uid = user?.uid else {
                        return
                    }
                    let values = ["name": self.nicknameField.text!,"email": self.emailField.text!, "RA": "false", "descript": ""]
                    let ref = FIRDatabase.database().referenceFromURL("https://dormy-e6239.firebaseio.com/")
                    let userRef = ref.child("users").child(uid)
                    userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            print(err)
                            return
                        }
                        // else error doesn't occur and we successfully entered user into database
                    })
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
}