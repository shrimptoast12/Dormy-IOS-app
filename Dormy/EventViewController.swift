//
//  EventViewController.swift
//  Dormy
//
//  Created by Tran, Viet Q on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//
import UIKit
class EventViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{
    
    var whichField:Bool?
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.tapHandler(_:)))
        view.addGestureRecognizer(tapRecognizer)
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