//
//  MainViewController.swift
//  Agario
//
//  Created by Michaelin on 15/9/26.
//  Copyright © 2015年 Michaelin. All rights reserved.
//


import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var playerSegmentedControl: UISegmentedControl!
    @IBOutlet weak var controlSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startGameBtnTouched(sender: AnyObject) {
        performSegueWithIdentifier("startGameSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //pass value into next viewcontroller
        if segue.identifier == "startGameSegue" {
            let nextViewController = segue.destinationViewController as! GameViewController
            if(playerSegmentedControl.selectedSegmentIndex == 0){
                nextViewController.isAIModel = true
            }else{
                nextViewController.isAIModel = false
            }
            if(controlSegmentedControl.selectedSegmentIndex == 0){
                nextViewController.isJoystick = true
            }else{
                nextViewController.isJoystick = false
            }
            if(playerNameTextField.text != nil){
                nextViewController.playerName = playerNameTextField.text!
            }
        }
    }
}