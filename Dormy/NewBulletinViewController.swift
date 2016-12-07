//
//  NewBulletinViewController.swift
//  Dormy
//
//  Created by Benjamin Lee on 12/7/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit


class NewBulletinViewController: UIViewController {
    
    @IBOutlet weak var EventButton: UIButton!
    @IBOutlet weak var QuestionButton: UIButton!
    @IBOutlet weak var AlertButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EventButton.layer.cornerRadius = 5
        EventButton.layer.borderWidth = 1
        EventButton.layer.borderColor = UIColor.clearColor().CGColor
        AlertButton.layer.cornerRadius = 5
        AlertButton.layer.borderWidth = 1
        AlertButton.layer.borderColor = UIColor.clearColor().CGColor
        QuestionButton.layer.cornerRadius = 5
        QuestionButton.layer.borderWidth = 1
        QuestionButton.layer.borderColor = UIColor.clearColor().CGColor
        
        
        
        // Do any additional setup after loading the view.
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
