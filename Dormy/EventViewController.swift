//
//  EventViewController.swift
//  Dormy
//
//  Created by Tran, Viet Q on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//
import UIKit
import Firebase

class EventViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{
    
    var whichField:Bool?
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // Create the bulletin post
    @IBAction func doneAction(sender: AnyObject) {
        if(titleTextField.text != "" || descriptionTextView.text != "") {
            let ref = FIRDatabase.database().reference().child("bulletin")
            let child = ref.childByAutoId()
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let timeStamp: NSNumber = Int(NSDate().timeIntervalSince1970)
                    let values: [String: AnyObject] = ["owner": (dictionary["name"] as? String)!,
                        "profileImage": (dictionary["imageURL"] as? String)!,
                        "description": self.descriptionTextView.text,
                        "startDate": self.startDateTextField.text!,
                        "endDate": self.endDateTextField.text!,
                        "image": "",
                        "timeStamp": timeStamp,
                        "postType": "event",
                        "title": self.titleTextField.text!]
                    
                    child.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            print(err)
                            return
                        }
                    })
                    //Post successful, Segue back to the main Bulletin Page
                    self.segueToBulletinWithSWReveal()
                }
                }, withCancelBlock: nil)
        }
        else {
            // Warn the user one of the fields is missing
            let alertController = UIAlertController(title: "Oops!", message: "Please enter a title or description!", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func segueToBulletinWithSWReveal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sw = storyboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        self.view.window?.rootViewController = sw
        let bulletin = self.storyboard?.instantiateViewControllerWithIdentifier("Bulletin") as! BulletinBoardTableViewController
        let navController = UINavigationController(rootViewController: bulletin)
        sw.pushFrontViewController(navController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.tapHandler(_:)))
        view.addGestureRecognizer(tapRecognizer)
        
        //Setting up textView UI
        self.descriptionTextView.layer.borderWidth = 1
        self.descriptionTextView.layer.borderColor = AppDelegate().RGB(80.0, g: 186.0, b: 99.0).CGColor
        self.descriptionTextView.layer.cornerRadius = 5
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startDateEditAction(sender: UITextField) {
        self.whichField = true
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EventViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    @IBAction func endDateEditAction(sender: UITextField) {
        self.whichField = false
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EventViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // function used to change the date picker and set it accordingly to the textfield
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a MMM dd, yyyy"
        if (whichField!) {
            startDateTextField.text = dateFormatter.stringFromDate(sender.date)
        }
        else {
            endDateTextField.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    
    // functions to dismiss keyboards and text fields
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        titleTextField.resignFirstResponder()
        return true
    }
    
    func tapHandler(gesture: UITapGestureRecognizer){
        titleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        startDateTextField.resignFirstResponder()
        endDateTextField.resignFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxChar: Int = 432
        return textView.text.characters.count + (text.characters.count - range.length) <= maxChar
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