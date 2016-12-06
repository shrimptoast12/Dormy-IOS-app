//
//  QuestionViewController.swift
//  Dormy
//
//  Created by Pritchett, Samuel B on 12/6/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate  {

    @IBOutlet weak var titleOfPost: UITextField!
    @IBOutlet weak var post: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.tapHandler(_:)))
        view.addGestureRecognizer(tapRecognizer)
        
        // Do any additional setup after loading the view.
        titleOfPost.delegate = self
        post.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
    titleOfPost.resignFirstResponder()
    post.resignFirstResponder()
    return true
    }
    
    func tapHandler(gesture: UITapGestureRecognizer){
        titleOfPost.resignFirstResponder()
        post.resignFirstResponder()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
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
