//
//  BackendlessManager.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/22/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import Foundation

// The BackendlessManager class below is using the Singleton pattern.
// A singleton class is a class which can be instantiated only once.
// In other words, only one instance of this class can ever exist.
// The benefit of a Singleton is that its state and functionality are
// easily accessible to any other object in the project.

class BackendlessManager {
	
	// This gives access to the one and only instance.
	static let sharedInstance = BackendlessManager()
	
	// This prevents others from using the default '()' initializer for this class.
	private init() {}
	
	
	let backendless = Backendless.sharedInstance()!
	
	
	let VERSION_NUM = "v1"
	let APP_ID = "2ECFFE12-41E3-DA72-FF9C-68AA8967D700"
	let SECRET_KEY = "AFE77CAD-2858-C0DA-FF8D-455A60FA4D00"
	
	let EMAIL = "test@gmail.com" // Doubles as User Name
	let PASSWORD = "password"
	
	func initApp() {
		
		// First, init Backendless!
		backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
		backendless.userService.setStayLoggedIn(true)
	}
	
	func isUserLoggedIn() -> Bool {
		
		let isValidUser = backendless.userService.isValidUserToken()
		
		if isValidUser != nil && isValidUser != 0 {
			return true
		} else {
			return false
		}
	}
	
	func registerTestUser() {
		
		let user: BackendlessUser = BackendlessUser()
		user.email = EMAIL as NSString!
		user.password = PASSWORD as NSString!
		
		backendless.userService.registering( user,
		                                     
			 response: { (user: BackendlessUser?) -> Void in

				print("User was registered: \(user?.objectId)")

				self.loginTestUser()
			},
		                                     
			 error: { (fault: Fault?) -> Void in
				print("User failed to register: \(fault)")

				print(fault?.faultCode)

				// If fault is for "User already exists." - go ahead and just login!
				if fault?.faultCode == "3033" {
					self.loginTestUser()
				}
			}
		)
	}
	
	func loginTestUser() {
		
		backendless.userService.login( self.EMAIL, password: self.PASSWORD,
		                               
		   response: { (user: BackendlessUser?) -> Void in
			print("User logged in: \(user!.objectId)")
		},
		                               
		   error: { (fault: Fault?) -> Void in
			print("User failed to login: \(fault)")
			
			}
		)
	}
	
	func saveTestData() {
		
		let newMeal = Meal()
		newMeal.name = "Test Meal #1"
		newMeal.photoUrl = "https://guildsa.org/wp-content/uploads/2016/09/meal1.png"
		newMeal.rating = 5
		
		backendless.data.save( newMeal,
		                       
		   response: { (entity: Any?) -> Void in
			
				let meal = entity as! Meal
			
				print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
			},
				   
			error: { (fault: Fault?) -> Void in
				print("Meal failed to save: \(fault)")
			}
		)
	}
	
	func loadTestData() {
		
		let dataStore = backendless.persistenceService.of(Meal.ofClass())
		
		dataStore?.find(
			
			{ (meals: BackendlessCollection?) -> Void in
				
				print("Find attempt on all Meals has completed without error!")
				print("Number of Meals found = \((meals?.data.count)!)")
				
				for meal in (meals?.data)! {
					
					let meal = meal as! Meal
					
					print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
				}
			},
			
			error: { (fault: Fault?) -> Void in
				print("Meals were not fetched: \(fault)")
			}
		)
	}
	
	func savePhotoAndThumbnail(mealToSave: Meal, photo: UIImage, completion: @escaping () -> (), error: @escaping () -> ()) {
		
		// Upload the thumbnail image
		
		let uuid = NSUUID().uuidString
		
		let size = photo.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
		let hasAlpha = false
		let scale: CGFloat = 0.1
		
		UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
		photo.draw(in: CGRect(origin: CGPoint.zero, size: size))
		
		let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 1.0);
		
		backendless.fileService.upload(
			"photos/\(backendless.userService.currentUser.objectId!)/thumb_\(uuid).jpg",
			content: thumbnailData,
			overwrite: true,
			response: { (uploadFile: BackendlessFile?) -> Void in
				
				mealToSave.thumbnailUrl = uploadFile?.fileURL!
				
				// Upload full size photo.
				
				let fullSizeData = UIImageJPEGRepresentation(photo, 0.2);
                
                self.backendless.fileService.upload(
                    "photos/\(self.backendless.userService.currentUser.objectId!)/full_\(uuid).jpg",
                    content: fullSizeData,
                    overwrite:true,
                    response: { (uploadedFile: BackendlessFile?) -> Void in
                        print("Photo image uploaded to: \(uploadedFile?.fileURL!)")
                        
                        mealToSave.photoUrl = uploadedFile?.fileURL!
                        
                        completion()
                    },
                    
                    error: { (fault: Fault?) -> Void in
                        print("Failed to save photo: \(fault)")
                        error()
                })
            },
            
            error: { (fault: Fault?) -> Void in
                print("Failed to save thumbnail: \(fault)")
                error()
        })
    }
	
func saveMeal(mealData: MealData, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        if mealData.objectId == nil {
            
            //
            // Create a new Meal along with a photo and thumbnail image.
            //
            
            let mealToSave = Meal()
            mealToSave.name = mealData.name
            mealToSave.rating = mealData.rating
            
            savePhotoAndThumbnail(mealToSave: mealToSave, photo: mealData.photo!,
                                                       
               completion: {
                
                    // Once we save the photo and its thumbnail - save the Meal!
                    self.backendless.data.save( mealToSave,

                       response: { (entity: Any?) -> Void in

                            let meal = entity as! Meal

                            print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")

                            mealData.objectId = meal.objectId
                            mealData.photoUrl = meal.photoUrl
                            mealData.thumbnailUrl = meal.thumbnailUrl
                        
                            completion()
                        },
                       
                       error: { (fault: Fault?) -> Void in
                            print("Failed to save Meal: \(fault)")
                            error()
                    })
                },
               
                error: {
                    print("Failed to save photo and thumbnail!")
                    error()
                })

        } else if mealData.replacePhoto {
            
            //
            // Update the Meal AND replace the existing photo and 
            // thumbnail image with a new one.
            //
            
            let mealToSave = Meal()
            
            savePhotoAndThumbnail(mealToSave: mealToSave, photo: mealData.photo!,
                                                       
               completion: {

                    let dataStore = self.backendless.persistenceService.of(Meal.ofClass())

                    dataStore?.findID(mealData.objectId,
                                      
                        response: { (meal: Any?) -> Void in
                            
                            // We found the Meal to update.
                            let meal = meal as! Meal
                            
                            // Cache old URLs for removal!
                            let oldPhotoUrl = meal.photoUrl!
                            let oldthumbnailUrl = meal.thumbnailUrl!
                            
                            // Update the Meal with the new data.
                            meal.name = mealData.name
                            meal.rating = mealData.rating
                            meal.photoUrl = mealToSave.photoUrl
                            meal.thumbnailUrl = mealToSave.thumbnailUrl
                            
                            // Save the updated Meal.
                            self.backendless.data.save( meal,
                                                   
                                response: { (entity: Any?) -> Void in
                                    
                                    let meal = entity as! Meal
                                    
                                    print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                                    
                                    // Update the mealData used by the UI with the new URLS!
                                    mealData.photoUrl = meal.photoUrl
                                    mealData.thumbnailUrl = meal.thumbnailUrl
                                    
                                    completion()
                                    
                                    // Attempt to remove the old photo and thumbnail images.
                                    self.removePhotoAndThumbnail(photoUrl: oldPhotoUrl, thumbnailUrl: oldthumbnailUrl, completion: {}, error: {})
                                },
                                                   
                               error: { (fault: Fault?) -> Void in
                                    print("Failed to save Meal: \(fault)")
                                    error()
                            })
                        },
                         
                        error: { (fault: Fault?) -> Void in
                            print("Failed to find Meal: \(fault)")
                            error()
                        }
                    )
                },
                                                       
                error: {
                    print("Failed to save photo and thumbnail!")
                    error()
                })
            
        } else {
            
            //
            // Update the Meal data but keep the existing photo and thumbnail image.
            //
            
            let dataStore = backendless.persistenceService.of(Meal.ofClass())

            dataStore?.findID(mealData.objectId,
                              
                response: { (meal: Any?) -> Void in
                    
                    // We found the Meal to update.
                    let meal = meal as! Meal
                    
                    // Update the Meal with the new data
                    meal.name = mealData.name
                    meal.rating = mealData.rating
                    
                    // Save the updated Meal.
                    self.backendless.data.save( meal,
                                           
                        response: { (entity: Any?) -> Void in
                            
                            let meal = entity as! Meal
                            
                            print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                            
                            completion()
                        },
                                           
                       error: { (fault: Fault?) -> Void in
                            print("Failed to save Meal: \(fault)")
                            error()
                    })
                },
                 
                error: { (fault: Fault?) -> Void in
                    print("Failed to find Meal: \(fault)")
                    error()
                }
            )
        }
    }
    
    func loadMeals(completion: @escaping ([MealData]) -> ()) {
        
        let dataStore = backendless.persistenceService.of(Meal.ofClass())
        
        let dataQuery = BackendlessDataQuery()
        // Only get the Meals that belong to our logged in user!
        dataQuery.whereClause = "ownerId = '\(backendless.userService.currentUser.objectId!)'"
        
        dataStore?.find( dataQuery,
            
            response: { (meals: BackendlessCollection?) -> Void in
                
                print("Find attempt on all Meals has completed without error!")
                print("Number of Meals found = \((meals?.data.count)!)")
                
                var mealData = [MealData]()
                
                for meal in (meals?.data)! {
                    
                    let meal = meal as! Meal
                    
                    print("Meal: \(meal.objectId!), name: \(meal.name), photoUrl: \"\(meal.photoUrl!)\", rating: \"\(meal.rating)\"")
                    
                    let newMealData = MealData(name: meal.name!, photo: nil, rating: meal.rating)
                    
                    if let newMealData = newMealData {
                        
                        newMealData.objectId = meal.objectId
                        newMealData.photoUrl = meal.photoUrl
                        newMealData.thumbnailUrl = meal.thumbnailUrl
                        
                        mealData.append(newMealData)
                    }
                }
                
                // Whatever meals we found on the database - return them.
                completion(mealData)
            },
            
            error: { (fault: Fault?) -> Void in
                print("Failed to find Meal: \(fault)")
            }
        )
    }
    
    func removeMeal(mealToRemove: MealData, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        print("Remove Meal: \(mealToRemove.objectId!)")
        
        let dataStore = backendless.persistenceService.of(Meal.ofClass())
        
        _ = dataStore?.removeID(mealToRemove.objectId,
                                
            response: { (result: NSNumber?) -> Void in

                print("One Meal has been removed: \(result)")
                completion()
            },
            
            error: { (fault: Fault?) -> Void in
                print("Failed to remove Meal: \(fault)")
                error()
            }
        )
    }
    
    func removePhotoAndThumbnail(photoUrl: String, thumbnailUrl: String, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        // Get just the file name which is everything after "/files/".
        let photoFile = photoUrl.components(separatedBy: "/files/").last

        backendless.fileService.remove( photoFile,
                                        
            response: { (result: Any!) -> () in
                print("Photo has been removed: result = \(result)")
                
                // Get just the file name which is everything after "/files/".
                let thumbnailFile = thumbnailUrl.components(separatedBy: "/files/").last
                
                self.backendless.fileService.remove( thumbnailFile,
                                                     
                    response: { (result: Any!) -> () in
                        print("Thumbnail has been removed: result = \(result)")
                        completion()
                    },
                    
                    error: { (fault : Fault?) -> () in
                        print("Failed to remove thumbnail: \(fault)")
                         error()
                    }
                )
            },
            
            error: { (fault : Fault?) -> () in
                print("Failed to remove photo: \(fault)")
                error()
            }
        )
    }
	
	func logoutUser(completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        // First, check if the user is actually logged in.
        if isUserLoggedIn() {
            
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
}
