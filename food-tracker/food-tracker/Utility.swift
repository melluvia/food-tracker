//
//  Utility.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/27/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import Foundation

class Utility {
	
	// This gives access to the one and only instance.
	static let sharedInstance = Utility()
	
	// This prevents others from using the default '()' initializer for this class.
	private init() {
    
        imageCache.countLimit = 50 // sets cache limit to 50 images.
    }
    
    // Create cache that uses NSString keys to point to UIImages.
    var imageCache = NSCache<NSString, UIImage>()
    
    func loadImageFromUrl(imageUrl: String, completion: @escaping (Data) -> (), loadError: @escaping () -> ()) {
        
        let url = URL(string: imageUrl)!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                do {
                    
                    let data = try Data(contentsOf: url, options: [])
                    
                    DispatchQueue.main.async {
                        
                        completion(data)
                    }
                    
                } catch {
                    print("NSData Error: \(error)")
                    DispatchQueue.main.async {
                        loadError()
                    }
                }
            } else {
                print("NSData Error: \(error)")
                DispatchQueue.main.async {
                    loadError()
                }
            }
        })
        
        task.resume()
    }

    
    
	static func isValidEmail(emailAddress: String) -> Bool {
		
		let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
		return emailPredicate.evaluate(with: emailAddress)
	}
	
	static func showAlert(viewController: UIViewController, title: String, message: String) {
		
		let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(okAction)
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	static func delayTask(seconds: Double, task: @escaping () -> ()) {
		
		let dispatchTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
			task()
		})
	}
}

