//
//  Meal.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/21/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class Meal : NSObject {
	
	var objectId: String?
	var name: String?
	var photoUrl: String?
	var rating: Int = 0
//

//	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//	// Don't forget to replace the App's ID and Secret Key in AppDelegate with YOUR own
//	// from YOUR Backendless Dashboard!
//	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//	
//	let EMAIL = "ios_user@gmail.com" // Doubles as User Name
//	let PASSWORD = "password"
//	
//	let backendless = Backendless.sharedInstance()!
//	
////	class Meal: NSObject {
////		
////		var name: String?
////		var rating: Int?
////
////	}
//	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		
//		checkForBackendlessSetup()
//		
//		//auto register
//		print( "registerBtn called!" )
//		
//		// In a real app, this where we would send the user to a register screen to collect their
//		// user name and password for registering a new user. For testing purposes, we will simply
//		// register a test user using a hard coded user name and password.
//		let user: BackendlessUser = BackendlessUser()
//		user.email = EMAIL as NSString!
//		user.password = PASSWORD as NSString!
//		
//		backendless.userService.registering( user,
//		                                     
//		                                     response: { (user: BackendlessUser?) -> Void in
//												print("User was registered: \(user?.objectId)")
//			},
//		                                     
//		                                     error: { (fault: Fault?) -> Void in
//												print("User failed to register: \(fault)")
//			}
//		)
//		
//		//auto login
//		
//		print( "loginBtn called!" )
//		
//		// First, check if the user is already logged in. If they are, we don't need to
//		// ask them to login again.
//		let isValidUser = backendless.userService.isValidUserToken()
//		
//		if isValidUser != nil && isValidUser != 0 {
//			
//			// The user has a valid user token so we know for sure the user is already logged!
//			print("User is already logged: \(isValidUser?.boolValue)");
//			
//		} else {
//			
//			// If we were unable to find a valid user token, the user is not logged in and they'll
//			// need to login. In a real app, this where we would send the user to a login screen to
//			// collect their user name and password for the login attempt. For testing purposes,
//			// we will simply login a test user using a hard coded user name and password.
//			
//			// Please note for a user to stay logged in, we had to make a call to
//			// backendless.userService.setStayLoggedIn(true) and pass true.
//			// This asks that the user should stay logged in by storing or caching the user's login
//			// information so future logins can be skipped next time the user launches the app.
//			// For this sample this call was made in the AppDelegate in didFinishLaunchingWithOptions.
//			
//			backendless.userService.login( EMAIL, password: PASSWORD,
//			                               
//			                               response: { (user: BackendlessUser?) -> Void in
//											print("User logged in: \(user!.objectId)")
//				},
//			                               
//			                               error: { (fault: Fault?) -> Void in
//											print("User failed to login: \(fault)")
//				}
//			)
//		}
//
//
//		// Do any additional setup after loading the view, typically from a nib.
//	}
//	
//	override func didReceiveMemoryWarning() {
//		super.didReceiveMemoryWarning()
//		// Dispose of any resources that can be recreated.
//	}
//	
//	func checkForBackendlessSetup() {
//		
//		let appDelegate = UIApplication.shared.delegate as! AppDelegate
//		
//		if appDelegate.APP_ID == "<replace-with-your-app-id>" || appDelegate.SECRET_KEY == "<replace-with-your-secret-key>" {
//			
//			let alertController = UIAlertController(title: "Backendless Error",
//			                                        message: "To use this sample you must register with Backendless, create an app, and replace the APP_ID and SECRET_KEY in the AppDelegate with the values from your app's settings.",
//			                                        preferredStyle: .alert)
//			
//			let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//			
//			alertController.addAction(okAction)
//			
//			self.present(alertController, animated: true, completion: nil)
//		}
//	}
	
//	 @IBAction func registerBtn(_ sender: UIButton) {
//		
//		checkForBackendlessSetup()
//		
//		print( "registerBtn called!" )
//		
//		// In a real app, this where we would send the user to a register screen to collect their
//		// user name and password for registering a new user. For testing purposes, we will simply
//		// register a test user using a hard coded user name and password.
//		let user: BackendlessUser = BackendlessUser()
//		user.email = EMAIL as NSString!
//		user.password = PASSWORD as NSString!
//		
//		backendless.userService.registering( user,
//		                                     
//		                                     response: { (user: BackendlessUser?) -> Void in
//												print("User was registered: \(user?.objectId)")
//			},
//		                                     
//		                                     error: { (fault: Fault?) -> Void in
//												print("User failed to register: \(fault)")
//			}
//		)
//	}
//		
//	@IBAction func loginBtn(_ sender: UIButton) {
//		
//		checkForBackendlessSetup()
//		
//		print( "loginBtn called!" )
//		
//		// First, check if the user is already logged in. If they are, we don't need to
//		// ask them to login again.
//		let isValidUser = backendless.userService.isValidUserToken()
//		
//		if isValidUser != nil && isValidUser != 0 {
//			
//			// The user has a valid user token so we know for sure the user is already logged!
//			print("User is already logged: \(isValidUser?.boolValue)");
//			
//		} else {
//			
//			// If we were unable to find a valid user token, the user is not logged in and they'll
//			// need to login. In a real app, this where we would send the user to a login screen to
//			// collect their user name and password for the login attempt. For testing purposes,
//			// we will simply login a test user using a hard coded user name and password.
//			
//			// Please note for a user to stay logged in, we had to make a call to
//			// backendless.userService.setStayLoggedIn(true) and pass true.
//			// This asks that the user should stay logged in by storing or caching the user's login
//			// information so future logins can be skipped next time the user launches the app.
//			// For this sample this call was made in the AppDelegate in didFinishLaunchingWithOptions.
//			
//			backendless.userService.login( EMAIL, password: PASSWORD,
//										   
//										   response: { (user: BackendlessUser?) -> Void in
//											print("User logged in: \(user!.objectId)")
//				},
//										   
//										   error: { (fault: Fault?) -> Void in
//											print("User failed to login: \(fault)")
//				}
//			)
//		}
//	}
	
//	@IBAction func logoutBtn(_ sender: UIButton) {
//		
//		checkForBackendlessSetup()
//		
//		print( "logoutBtn called!" )
//		
//		// First, check if the user is actually logged in.
//		let isValidUser = backendless.userService.isValidUserToken()
//		
//		if isValidUser != nil && isValidUser != 0 {
//			
//			// If they are currently logged in - go ahead and log them out!
//			
//			backendless.userService.logout( { (user: Any!) -> Void in
//				print("User logged out!")
//				},
//											
//											error: { (fault: Fault?) -> Void in
//												print("User failed to log out: \(fault)")
//				}
//			)
//			
//		} else {
//			
//			// If we were unable to find a valid user token, the user is already logged out.
//			
//			print("User is already logged out: \(isValidUser?.boolValue)");
//		}
//	}

}
