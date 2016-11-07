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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4  {
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
