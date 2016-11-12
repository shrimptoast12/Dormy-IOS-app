//
//  MenuController.swift
//  Dormy
//
//  Created by Benjamin Lee on 11/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class MenuController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Note, I have no idea why, but static cells always appear darker than the colors they are programatically set to, whether through RGB() or the storyboard. I have tinkered around manually to have the first static cell match the rest of the colors. The values are RGB(238.0,212.0,152.0) with 88% opacity. Hex is EED498
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Log out cell tapped
        if indexPath.row == 5  {
            try! FIRAuth.auth()?.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewControllerWithIdentifier("login") as! ViewController
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
