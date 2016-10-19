//
//  RegisterViewController.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/27/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var registerBtn: UIButton!
    
    let backendless = Backendless.sharedInstance()!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(LoginViewController.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    }

    func textFieldChanged(textField: UITextField) {
        
        if emailTextField.text == "" || passwordTextField.text == "" || passwordConfirmTextField.text == "" {
            registerBtn.isEnabled = false
        } else {
            registerBtn.isEnabled = true
        }
    }
    
    
    func registerUser(email: String, password: String, completion: @escaping () -> (), error: @escaping (String) -> ()) {
    
        let user: BackendlessUser = BackendlessUser()
        user.email = email as NSString!
        user.password = password as NSString!
        
        backendless.userService.registering( user,
                                              
            response: { (user: BackendlessUser?) -> Void in
            
                print("User was registered: \(user?.objectId)")
                completion()
            },
          
            error: { (fault: Fault?) -> Void in
                print("User failed to register: \(fault)")
                error((fault?.message)!)
            }
        )
    }
    
    func loginUser(email: String, password: String, completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        backendless.userService.login( email, password: password,
                                        
            response: { (user: BackendlessUser?) -> Void in
                print("User logged in: \(user!.objectId)")
                completion()
            },
            
            error: { (fault: Fault?) -> Void in
                print("User failed to login: \(fault)")
                error((fault?.message)!)
            })
    }
    

    @IBAction func register(_ sender: UIButton) {
        
        if !Utility.isValidEmail(emailAddress: emailTextField.text!) {
            Utility.showAlert(viewController: self, title: "Registration Error", message: "Please enter a valid email address.")
            return
        }

        if passwordTextField.text != passwordConfirmTextField.text {
            Utility.showAlert(viewController: self, title: "Registration Error", message: "Password confirmation failed. Plase enter your password try again.")
            return
        }
        
        spinner.startAnimating()
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        BackendlessManager.sharedInstance.registerUser(email: email, password: password,
            completion: {
                
                BackendlessManager.sharedInstance.loginUser(email: email, password: password,
                    completion: {
                    
                        self.spinner.stopAnimating()
                        
                        self.performSegue(withIdentifier: "gotoMenuFromRegister", sender: sender)
                    },
                    
                    error: { message in
                        
                        self.spinner.stopAnimating()
                        
                        Utility.showAlert(viewController: self, title: "Login Error", message: message)
                    })
            },
            
            error: { message in
                
                self.spinner.stopAnimating()
                
                Utility.showAlert(viewController: self, title: "Register Error", message: message)
            })
    }
    
    // MARK: UITextFieldDelegate
    
    // UITextFieldDelegate, called when Return tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        
        if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()
            
        } else if textField == passwordTextField {
            
            passwordConfirmTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            
            if passwordTextField.text != passwordConfirmTextField.text {
                
                registerBtn.isEnabled = false                
            }
        }
        
        return true
    }


    func logoutUser(completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        // First, check if the user is actually logged in.
        if BackendlessManager.sharedInstance.isUserLoggedIn() {
            
            // If they are currently logged in - go ahead and log them out!
            
            backendless.userService.logout( { (user: Any!) -> Void in
                print("User logged out!")
                completion()
                },
                                            
                                            error: { (fault: Fault?) -> Void in
                                                print("User failed to log out: \(fault)")
                                                error((fault?.message)!)
            })
            
        } else {
            
            print("User is already logged out!");
            completion()
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
        spinner.stopAnimating()
        
        dismiss(animated: true, completion: nil)
    }
}

