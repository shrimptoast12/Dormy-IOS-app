//
//  LaundryHelperTableViewController.swift
//  Dormy
//
//  Created by Tran, Viet Q on 11/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase

class LaundryHelperTableViewController: UITableViewController {
    
    @IBOutlet weak var addMachine: UIBarButtonItem!
    var users = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "Laundry Helper"
        let user = FIRAuth.auth()?.currentUser
        let uid = user?.uid
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let raFlag = dictionary["RA"] as? String
                self.addMachine.enabled = false
                self.addMachine.tintColor = UIColor.clearColor()
                if (raFlag == "true") {
                    self.addMachine.enabled = true
                    self.addMachine.tintColor = nil
                }
            }
            
            }, withCancelBlock: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("laundryCell", forIndexPath: indexPath) as! LaundryTableViewCell
        //cell.laundryIcon?.image = UIImage(named: "dryer")
        
        FIRDatabase.database().reference().child("laundry").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                if let laundryImageURL = dictionary["dryerIcon"] as? String {
                    let url = NSURL(string: laundryImageURL)
                    NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                        if (error != nil) {
                            print(error)
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.laundryIcon?.image = UIImage(data: data!)
                        })
                    }).resume()
                }
            }
            
            }, withCancelBlock: nil)
        
        //  if let profileImageURL = ref {
        
        //}
        
        // Configure the cell...
        
        return cell
    }
    
    @IBAction func addMachineAction(sender: AnyObject) {
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
