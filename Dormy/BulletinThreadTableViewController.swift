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
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Bulletin Board", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(BulletinThreadTableViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadList:"), name: "notification", object: nil)
        fetchComments()
    }
    
    // Fixes a bug that caused the new subComment to not appear after.
    func loadList(notification:NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        comments.removeAll()
        fetchComments()
        self.tableView.reloadData()
    }
    
    // function used to fetch comments to load into the table vieiw
    func fetchComments() {
        FIRDatabase.database().reference().child("bulletin").child(post.postId!).child("comments").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                // appends comments to the comment array to load in table view
                let comment = Comment()
                let key = snapshot.key
                comment.setCommentWithDictionary(dictionary, commentId: key, type: false)
                self.comments.append(comment)
                // appends nested sub-comments if they exist
                if(dictionary["nested"] != nil) {
                    let temp = dictionary["nested"] as? [String: AnyObject]
                    let tempKey: [String] = Array(temp!.keys)
                    var subComments = [Comment]()
                    for a in 0 ..< tempKey.count {
                        let subComment = Comment()
                        let temp2 = temp![tempKey[a]] as? [String: AnyObject]
                        subComment.setCommentWithDictionary(temp2!, commentId: tempKey[a], type: true)
                        subComments.append(subComment)
                    }
                    subComments.sortInPlace({ (comment1, comment2) -> Bool in
                        comment1.timeStamp!.doubleValue < comment2.timeStamp!.doubleValue
                    })
                    self.comments += subComments
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
            }, withCancelBlock: nil)
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
        return comments.count + 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    // load the table view for the post/comment thread
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Sets the original post as the first cell
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath) as! ThreadPostTableViewCell
            // Configure the cell...
            tableView.rowHeight = 264
            if (post.postType == "event"){
                cell.startTimeLabel.text = post.startDate!
                cell.endTimeLabel.text = post.endDate!
                cell.startLabel.hidden = false
                cell.endLabel.hidden = false
                cell.startTimeLabel.hidden = false
                cell.endTimeLabel.hidden = false
                
            } else {
                cell.startLabel.hidden = true
                cell.endLabel.hidden = true
                cell.startTimeLabel.hidden = true
                cell.endTimeLabel.hidden = true
            }
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
        else if(comments[indexPath.row - 1].commentType == false){
            // Sets regular comment cells
            let cell = tableView.dequeueReusableCellWithIdentifier("commentId", forIndexPath: indexPath) as! CommentCell
            tableView.rowHeight = 150
            let comment = comments[indexPath.row - 1]
            let url = NSURL(string: comment.profileImage!)
            let timeStampDate = NSDate(timeIntervalSince1970: comment.timeStamp!.doubleValue)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a MM/dd/yy"
            cell.timeStamp?.text = dateFormatter.stringFromDate(timeStampDate)
            
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if (error != nil) {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    cell.profileImage?.image = UIImage(data: data!)
                })
            }).resume()
            cell.replyButton.tag = indexPath.row - 1
            cell.nameLabel?.text = comment.user!
            cell.commentLabel?.text = comment.comment!
            return cell
        } else {
            // Sets sub-comment cells
            let cell = tableView.dequeueReusableCellWithIdentifier("subCommentId", forIndexPath: indexPath) as! SubCommentCell
            tableView.rowHeight = 150
            let comment = comments[indexPath.row - 1]
            let url = NSURL(string: comment.profileImage!)
            let timeStampDate = NSDate(timeIntervalSince1970: comment.timeStamp!.doubleValue)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "h:mm a MM/dd/yy"
            cell.timeStamp?.text = dateFormatter.stringFromDate(timeStampDate)
            
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if (error != nil) {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageProfile?.image = UIImage(data: data!)
                })
            }).resume()
            cell.nameLabel?.text = comment.user!
            cell.commentLabel?.text = comment.comment!
            return cell
        }
    }
    
    // Function that allows you to go back to the bulletin board when you're in the thread post
    func back(sender: UIBarButtonItem) {
        performSegueWithIdentifier("backToBoard", sender: sender)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let index = sender!.tag
        if (segue.identifier == "writeCommentSegue") {
            let destination = segue.destinationViewController as? WriteCommentViewController
            destination?.post = post
            destination?.nested = false
        }
        
        if (segue.identifier == "nestedCommentSegue") {
            let destination = segue.destinationViewController as? WriteCommentViewController
            destination?.post = post
            destination?.nested = true
            destination?.commentId = comments[index].commentId!
            destination?.table = self
        }
    }
}