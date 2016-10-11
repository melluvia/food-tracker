//
//  MealViewController.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/14/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

	// MARK: Properties
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var ratingControl: RatingControl!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var saveSpinner: UIActivityIndicatorView!
	@IBOutlet weak var notesView: UITextView!
	@IBOutlet weak var scrollView: UIScrollView!
	/*
	This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
	or constructed as part of adding a new meal.
	*/
	var meal: MealData?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		// Handle the text field’s user input through delegate callbacks.
		nameTextField.delegate = self
		notesView.delegate = self
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            
            if BackendlessManager.sharedInstance.isUserLoggedIn() && meal.photoUrl != nil {
                loadImageFromUrl(imageView: photoImageView, photoUrl: meal.photoUrl!)
            } else {
                photoImageView.image = meal.photo
            }
            
            ratingControl.rating = meal.rating
			notesView.text = meal.note
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
		
		registerForKeyboardNotifications()
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: UITextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		// Hide the keyboard.
		//textField.resignFirstResponder()
		
		if textField == notesView {
			notesView.resignFirstResponder()
		}
		
		return true
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Disable the Save button while editing.
		saveButton.isEnabled = false
	}
	
	func checkValidMealName() {
		// Disable the Save button if the text field is empty.
		let text = nameTextField.text ?? ""
		saveButton.isEnabled = !text.isEmpty
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		checkValidMealName()
		navigationItem.title = textField.text
	}
	
	// MARK: UIImagePickerControllerDelegate
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		// Dismiss the picker if the user canceled.
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		// The info dictionary contains multiple representations of the image, and this uses the original.
		let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
		
		// If we already have a URL for an image - the user wants to do an image replacement.
		if meal?.photoUrl != nil {
			meal?.replacePhoto = true
		}
		
		// Set photoImageView to display the selected image.
		photoImageView.image = selectedImage
		
		// Dismiss the picker.
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: Navigation
	
	@IBAction func save(_ sender: UIBarButtonItem) {
		
		saveButton.isEnabled = false
		
		let name = nameTextField.text ?? ""
		let rating = ratingControl.rating
		let photo = photoImageView.image
		let note = notesView.text ?? ""
		
		saveSpinner.isHidden = false
		saveSpinner.startAnimating()
		
		if meal == nil {
			
			meal = MealData(name: name, photo: photo, rating: rating, note: note)
			
		} else {
			
			meal?.name = name
			meal?.photo = photo
			meal?.rating = rating
			meal?.note = note
		}
		
		if BackendlessManager.sharedInstance.isUserLoggedIn() {
			
			// We're logged in - attempt to save to Backendless!
			self.saveSpinner.startAnimating()
			
			BackendlessManager.sharedInstance.saveMeal(mealData: meal!,
														
               completion: {
                
                    // It was saved to the database!
                    self.saveSpinner.stopAnimating()
                
                    self.meal?.replacePhoto = false // Reset this just in case we did a photo replacement.

                    self.performSegue(withIdentifier: "unwindToMealList", sender: self)
                },
                                                       
               error: {
                
                    // It was NOT saved to the database! - tell the user and DON'T call performSegue.
                    self.saveSpinner.stopAnimating()
                    
                    let alertController = UIAlertController(title: "Save Error",
                                                            message: "Oops! We couldn't save your Meal at this time.",
                                                            preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                
                    self.saveButton.isEnabled = true
                })
            
        } else {
            
            // We're not logged in - just unwind and have MealTableViewController 
            // save later using NSKeyedArchiver.
            self.performSegue(withIdentifier: "unwindToMealList", sender: self)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    // MARK: Actions

    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func loadImageFromUrl(imageView: UIImageView, photoUrl: String) {
        
        saveSpinner.startAnimating()
        
        let url = URL(string: photoUrl)!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                do {
                    
                    let data = try Data(contentsOf: url, options: [])
                    
                    DispatchQueue.main.async {
                        
                        // We got the image data! Use it to create a UIImage for our cell's
                        // UIImageView.
                        imageView.image = UIImage(data: data)
                        self.saveSpinner.stopAnimating()
                    }
                    
                } catch {
                    print("NSData Error: \(error)")
                }
                
            } else {
                print("NSURLSession Error: \(error)")
            }
        })
        
        task.resume()
    }
	
//	// Method gets called when the keyboard return key pressed
//	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//		print("textFieldShouldReturn")
//		
//		notesView.resignFirstResponder()
//		
//		return true
//	}
//	
	//Make the text field move up upon keyboard popping up
	
	func registerForKeyboardNotifications() {
		
		//Adding notifies on keyboard appearing
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	func deregisterFromKeyboardNotifications() {
		
		//Removing notifies on keyboard appearing
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	func keyboardWasShown(notification: NSNotification) {
		
		//Need to calculate keyboard exact size due to Apple suggestions
		self.scrollView.isScrollEnabled = true
		let info : NSDictionary = notification.userInfo! as NSDictionary
		let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
		let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
		
		self.scrollView.contentInset = contentInsets
		self.scrollView.scrollIndicatorInsets = contentInsets
		
		var aRect : CGRect = self.view.frame
		aRect.size.height -= keyboardSize!.height
		if (notesView) != nil {
			if (!aRect.contains(notesView!.frame.origin)) {
				self.scrollView.scrollRectToVisible(notesView!.frame, animated: true)
			}
		}
	}
	
	func keyboardWillBeHidden(notification: NSNotification) {
		
		//Once keyboard disappears, restore original positions
		let info : NSDictionary = notification.userInfo! as NSDictionary
		let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
		let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
		self.scrollView.contentInset = contentInsets
		self.scrollView.scrollIndicatorInsets = contentInsets
		self.view.endEditing(true)
		self.scrollView.isScrollEnabled = false
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		//notesView = textView
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		//notesView = nil
	}
}

