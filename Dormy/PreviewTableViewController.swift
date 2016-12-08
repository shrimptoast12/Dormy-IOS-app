//
//  PreviewTableViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/8/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class PreviewTableViewController: UITableViewController {

    var post: Post?
    var postType: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var titleOfPost: String = ""
    var userName: String = ""
    var timeStamp: NSNumber = 0
    var postImage: String = ""
    var descript: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadList:"), name: "load", object: nil)
    }

    func loadList(notification:NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        postType = post!.postType!
        if (post!.postType == "event"){
            startTime = post!.startDate!
            endTime = post!.endDate!
            
        }
        titleOfPost = post!.title!
        userName = post!.owner!
        timeStamp = post!.timeStamp!
        postImage = post!.profileImage!
        descript = post!.description!
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
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
        let cell = tableView.dequeueReusableCellWithIdentifier("previewCell", forIndexPath: indexPath) as? PreviewTableViewCell
        
        if (postType == "event"){
            cell!.startTimeLabel.text = startTime
            cell!.endTimeLabel.text = endTime
            cell!.startLabel.hidden = false
            cell!.endLabel.hidden = false
            cell!.startTimeLabel.hidden = false
            cell!.endTimeLabel.hidden = false
            
        } else {
            cell!.startLabel.hidden = true
            cell!.endLabel.hidden = true
            cell!.startTimeLabel.hidden = true
            cell!.endTimeLabel.hidden = true
        }
        cell!.postDescription.text = descript
        cell!.titleOfPost.text = titleOfPost
        cell!.userName.text = userName
        let timeStampDate = NSDate(timeIntervalSince1970: timeStamp.doubleValue)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a MM/dd/yy"
        cell!.timeStamp.text = dateFormatter.stringFromDate(timeStampDate)
        let url = NSURL(string: postImage)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            if (error != nil) {
                print(error)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                cell!.postImage.image = UIImage(data: data!)
            })
        }).resume()

        return cell!
    }
}
