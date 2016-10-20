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
	
    @IBOutlet weak var restaurantNameTextField: UITextField!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var ratingControl: RatingControl!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var saveSpinner: UIActivityIndicatorView!
	@IBOutlet weak var notesView: UITextView!
	@IBOutlet weak var scrollView: UIScrollView!
    
    var addingNewItem: Bool? = false
    
    
	/*
	This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
	or constructed as part of adding a new meal.
	*/
	var meal: MealData?
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        let userId = BackendlessManager.sharedInstance.backendless.userService.currentUser.objectId!
        
        if addingNewItem == false && userId as String != meal?.ownerId {
            
            restaurantNameTextField.isEnabled = false
            nameTextField.isEnabled = false
            photoImageView.isUserInteractionEnabled = false
            notesView.isEditable = false
        }

	
		// Handle the text field’s user input through delegate callbacks.
		nameTextField.delegate = self
		notesView.delegate = self
		notesView.text = "Describe the dish or recipe..."
		notesView.textColor = UIColor.lightGray
        
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
            restaurantNameTextField.text = meal.restaurantName
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
		
		if textField == restaurantNameTextField {
			nameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true

	}
    
    // UITextFieldDelegate, called when editing session begins, or when keyboard displayed
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        saveButton.isEnabled = false
        
//        // Create padding for textFields
//        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
//        
//        textField.leftView = paddingView
//        textField.leftViewMode = UITextFieldViewMode.always
//        
//        if textField == restaurantNameTextField {
//            restaurantNameTextField.placeholder = "Restaurant Name"
//        } else {
//            nameTextField.placeholder = "Dish Title"
//        }
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
    
    // MARK: UITextViewDelegate methods
    
    // Chance to edit Content upon editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // Removes All Content upon editing
        if notesView.text == "Describe the dish or recipe..." {
            notesView.text = nil
            notesView.textColor = UIColor.white
        }
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if notesView.textColor == UIColor.lightGray {
//            notesView.text = nil
//            notesView.textColor = UIColor.black
//        }
//    }
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if notesView.text.isEmpty {
//            notesView.text = "Placeholder"
//            notesView.textColor = UIColor.lightGray
//        }
//    }
    
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        
//        // Resign keyboard upon return
//        if(text == "\n") {
//            view.endEditing(true)
//            return false
//        } else {
//            return true
//        }
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a Description..."
            textView.textColor = UIColor.lightGray
        }
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
        let restaurantName = restaurantNameTextField.text ?? ""
		
		saveSpinner.isHidden = false
		saveSpinner.startAnimating()
		
		if meal == nil {
			
            meal = MealData(name: name, photo: photo, rating: rating, note: note, restaurantName: restaurantName)
			
		} else {
			
			meal?.name = name
			meal?.photo = photo
			meal?.rating = rating
			meal?.note = note
            meal?.restaurantName = restaurantName
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

    // Added actionsheet to allow user to pick photo library or camera
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        let alertController = UIAlertController(title: nil,
            message: "How would you like to add the dish image?",
            preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "By Camera", style: .default) { action in
            print("Camera was selected!")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(cameraAction)

        let photoLibraryAction = UIAlertAction(title: "By Photo Library", style: .default) { action in
            print("Photo Library was selected!")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                // SIMILAR TO WHAT WE HAD BEFORE
                // UIImagePickerController is a view controller that lets a user pick media from their photo library.
                let imagePicker = UIImagePickerController()
                // Make sure ViewController is notified when the user picks an image.
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(photoLibraryAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel was selected!")
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            print("Show the Action Sheet!")
        }
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
		
		// Find out how high the keyboard is on the device.
		var userInfo = notification.userInfo!
		var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = self.view.convert(keyboardFrame, from: nil)
		
		// Pad the bottom of the contentInset by the keyboard's hieght.
		// This will cause the scroll view to animate up if required.
		var contentInset: UIEdgeInsets = self.scrollView.contentInset
		contentInset.bottom = keyboardFrame.size.height
		self.scrollView.contentInset = contentInset
	}
	
	func keyboardWillBeHidden(notification: NSNotification) {
		
		// Reset the scroll view back to where it was!
		self.scrollView.contentInset = UIEdgeInsets.zero
	}
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "unwindToMealList" {
//            
//        }
//    }

}

