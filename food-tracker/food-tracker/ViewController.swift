//
//  ViewController.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/14/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: Properties

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var mealNameLabel: UILabel!

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		nameTextField.delegate = self
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	// MARK: UITextFieldDelegate
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		// hide the keyboard
		
		textField.resignFirstResponder()
		
		return true
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		
		mealNameLabel.text = textField.text
	}
	// MARK: Actions
	@IBAction func setDefaultLabelText(sender: UIButton) {
		
		mealNameLabel.text = "Default Text"
	}
}

