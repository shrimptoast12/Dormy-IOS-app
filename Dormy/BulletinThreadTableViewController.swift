//
//  BulletinThreadTableViewController.swift
//  Dormy
//
//  Created by Benjamin Lee on 11/20/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Firebase
class BulletinThreadTableViewController: UITableViewController {

    var post = Post()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 264
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Bulletin Board", style: UIBarButtonItemStyle.Bordered, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath) as! ThreadPostTableViewCell
        // Configure the cell...
        cell.postTitleLabel?.text = post.title!
        cell.nameLabel?.text = post.owner!
        let timeStampDate = NSDate(timeIntervalSince1970: post.timeStamp!.doubleValue)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a MM/dd/yy"
        cell.timeStampLabel?.text = dateFormatter.stringFromDate(timeStampDate)
        cell.descriptionLabel?.text = post.description!
        let url = NSURL(string: post.profileImage!)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            if (error != nil) {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), { 
                cell.userImage?.image = UIImage(data: data!)
            })
        }).resume()
        
        return cell
    }
 
    func back(sender: UIBarButtonItem) {
        performSegueWithIdentifier("backToBoard", sender: sender)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "writeCommentSegue") {
            let destination = segue.destinationViewController as? WriteCommentViewController
            destination?.post = post
        }
    }
 

}
