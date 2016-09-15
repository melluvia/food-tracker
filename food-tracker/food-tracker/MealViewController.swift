//
//  MealViewController.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/14/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	// MARK: Properties

	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var ratingControl: RatingControl!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	/*
 This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
 or constructed as part of adding a new meal.
 */
	var meal: Meal?

	
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
		
		
	}
	// MARK: UIImagePickerControllerDelegate
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		
		// Dismiss the picker if the user canceled.
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		
		// The info dictionary contains multiple representations of the image, and this uses the original.
		let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
		
		// Set photoImageView to display the selected image.
		photoImageView.image = selectedImage
		
		// Dismiss the picker.
		dismissViewControllerAnimated(true, completion: nil)
	}
	// MARK: Actions
	@IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
		
		// Hide the keyboard.
		nameTextField.resignFirstResponder()
		
		// UIImagePickerController is a view controller that lets a user pick media from their photo library.
		
		let imagePickerController = UIImagePickerController()
		
		// Only allow photos to be picked, not taken.
		imagePickerController.sourceType = .PhotoLibrary
		
		// Make sure ViewController is notified when the user picks an image.
		imagePickerController.delegate = self
		
		presentViewController(imagePickerController, animated: true, completion: nil)
	}
}

