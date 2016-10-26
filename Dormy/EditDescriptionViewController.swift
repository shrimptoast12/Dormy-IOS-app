//
//  EditDescriptionViewController.swift
//  Dormy
//
//  Created by Viet Tran on 10/24/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class EditDescriptionViewController: UIViewController {
    
    weak var vc:UserProfileViewController?

    @IBOutlet weak var myTextView: UITextView!
    
    @IBAction func cancel(sender: AnyObject) {
        //TODO
        //Would like to change this to an animation that slides back left
        //Right now it slides up and down, you can see the status bar and the nav bar disconnect
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        myTextView.text = vc!.textF.text
        // Do any additional setup after loading the view.
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
            FIRDatabase.database().reference().child("users").child(uid!).child("descript").setValue(descript)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
