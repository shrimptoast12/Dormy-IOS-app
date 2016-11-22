//
//  SettingsViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 11/22/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var currentName: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
