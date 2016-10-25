//
//  MealTableViewController.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/15/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController {
	
	// MARK: Properties
	
	var meals = [MealData]()
    var filteredMeals = [MealData]()
    
    var isDeleting: Bool = false
    
	// Create cache that uses NSString keys to point to UIImages.
	var imageCache = NSCache<NSString, UIImage>()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageCache.countLimit = 50 // sets cache limit to 50 images.

        // Add support for pull-to-refresh on the table view.
        self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
		
		// sets edit button to white
		self.navigationController?.navigationBar.tintColor = UIColor.white
        
//        // set image on bar button item
//		let img = UIImage(named: "edit-symbol")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//		
//		let leftBarButtonItem = UIBarButtonItem(image: img,
//		                                        style: UIBarButtonItemStyle.plain,
//		                                        target: self,
//		                                        action: #selector(onEditBtn(sender:)))
//			
//			
//		self.navigationItem.leftBarButtonItem = leftBarButtonItem
		
        if !BackendlessManager.sharedInstance.isUserLoggedIn() {
            
            // Load any saved meals, otherwise load sample data.
            // if user is not logged in, we use the archiver
            if let savedMeals = loadMealsFromArchiver() {
                meals += savedMeals
            } else {
                
                loadSampleMeals()
            }
        } else {
    
        refresh(sender: self)
    }

		///				//sort the meals from highest to lowest rating
////TODO: WHO IS SORTING MEALS???????????????????????????????????
//				self.meals.sort {
//					
//                       $0.rating > $1.rating

        
    }
    
    func refresh(sender: AnyObject) {
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() {
            
            // Updated loadMeals in BEManager to throw error if fails
            BackendlessManager.sharedInstance.loadMeals(
                
                completion: { mealData in
                    
                    // remove the += or else we duplicate the meals
                    self.meals = mealData
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                },
                
                error: {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
            })
        } else {
            refreshControl!.endRefreshing()
        }

    }
    
    func onEditBtn(sender: UIBarButtonItem) {
        
        if isDeleting == true {
            
            isDeleting = false
            
        } else {
            
           isDeleting = true
        }
        
        print("\(isDeleting)")
        
        filterMealsByOwner()
        
        self.tableView.isEditing = !self.tableView.isEditing
        
        refresh(sender: self)
        
    }
    
    func filterMealsByOwner() {
        
        filteredMeals = []
        
        let userId = BackendlessManager.sharedInstance.backendless.userService.currentUser.objectId!
        
        for meal in meals {
            
            if meal.ownerId  == userId as String {
                
                filteredMeals.append(meal)
            }
        }
        tableView.reloadData()
    }
    
    func loadSampleMeals() {
        
        let photo1 = UIImage(named: "meal1")!
        let meal1 = MealData(name: "Caprese Salad", photo: photo1, rating: 4, note: "A great Salad!", restaurantName: "My Kitchen!!")!
        
        let photo2 = UIImage(named: "meal2")!
        let meal2 = MealData(name: "Chicken and Potatoes", photo: photo2, rating: 5, note: "Gotta Love Chicken!", restaurantName: "My mom's house")!
        
        let photo3 = UIImage(named: "meal3")!
        let meal3 = MealData(name: "Pasta with Meatballs", photo: photo3, rating: 3, note: "Just average.", restaurantName: "Denny's")!
        
        meals += [meal1, meal2, meal3]
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDeleting == true {
            return filteredMeals.count
        }
        
        return meals.count

    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Table view cells are reused and should be dequeued using a cell identifier.
		let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell", for: indexPath) as! MealTableViewCell
        
        let meal: MealData
        
        if isDeleting == true {
            meal = filteredMeals[indexPath.row]
        } else {
            meal = meals[indexPath.row]
        }
        
		cell.nameLabel.text = meal.name
        cell.ratingControl.rating = meal.rating 
        
        cell.avgRatingLabel.text = String(AvgRating.init().calcAvgRating(meal.rating, pastRating: meal.prevRating))
        
        
        print("the avg rating label is at \(cell.avgRatingLabel.text)")
        
        
        // For NSCache, if we have the cache key we put it on the cell when it gets created
        if BackendlessManager.sharedInstance.isUserLoggedIn() && meal.photoUrl != nil {
            
            if imageCache.object(forKey: meal.thumbnailUrl! as NSString) != nil {
                
                // If the URL for the thumbnail is in the cache already - get the UIImage that belongs to it.
                cell.photoImageView.image = imageCache.object(forKey: meal.thumbnailUrl! as NSString)
                
            } else {
                
                cell.spinner.startAnimating()
                
                loadImageFromUrl(thumbnailUrl: meal.thumbnailUrl!,
                                 
                    completion: { data in
                        // retrieved data- using it to create a UIImage for our cell's ui imageview.
                        if let image = UIImage(data: data) {
                                        
                            cell.photoImageView.image = image
                                        
                            // cache the pulled down UIImage using the URL as the key.
                            self.imageCache.setObject(image, forKey: meal.thumbnailUrl! as NSString)
                        }
                                    
                        cell.spinner.stopAnimating()
                    },
                                 
                    loadError: {
                        cell.spinner.stopAnimating()
                })
            }
            
        }
        else {
            cell.photoImageView.image = meal.photo
        }
  //      }
		return cell
	}
	
	func loadImageFromUrl(thumbnailUrl: String, completion: @escaping (Data) -> (), loadError: @escaping () -> ()) {
		
		let url = URL(string: thumbnailUrl)!
		
		let session = URLSession.shared
		
		let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
			
			if error == nil {
				
				do {
					
					let data = try Data(contentsOf: url, options: [])
					
					DispatchQueue.main.async {
						
						// We got the image data! Use it to create a UIImage for our cell's
						// UIImageView. Then, stop the activity spinner.
						completion(data)
						//cell.activityIndicator.stopAnimating()
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
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			
			if BackendlessManager.sharedInstance.isUserLoggedIn() {
				
				// Find the MealData in the data source that we wish to delete.
				let mealToRemove = filteredMeals[indexPath.row]
                
                    BackendlessManager.sharedInstance.removeMeal(mealToRemove: mealToRemove,
				                                             
                        completion: {
						
                            // It was removed from the database, now delete the row from the data source.
                            self.filteredMeals.remove(at: (indexPath as NSIndexPath).row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        },
									 
                        error: {
						
                            // It was NOT removed - tell the user and DON'T delete the row from the data source.
                            let alertController = UIAlertController(title: "Remove Failed",
                                message: "Oops! We couldn't remove your Meal at this time.",
                                preferredStyle: .alert)

                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
					
                            self.present(alertController, animated: true, completion: nil)
                    })

			} else {
				
				// Delete the row from the data source
				meals.remove(at: (indexPath as NSIndexPath).row)
				
				// Save the meals.
				saveMealsToArchiver()
				
				tableView.deleteRows(at: [indexPath], with: .fade)
			}
			
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
	
	// MARK: - Navigation
	

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "ShowDetail" {
			
			let mealDetailViewController = segue.destination as! MealViewController
			
			// Get the cell that generated this segue.
			if let selectedMealCell = sender as? MealTableViewCell {
				
				let indexPath = tableView.indexPath(for: selectedMealCell)!
				let selectedMeal = meals[(indexPath as NSIndexPath).row]
				mealDetailViewController.meal = selectedMeal
                
                //dont forget to save the current rating as previous rating 
                if selectedMeal.prevRating != nil{
                    selectedMeal.prevRating!.append(String(selectedMeal.rating) + ",")
                    //save it to backendless
                    //Backendless.sharedInstance().data.
                } else {
                    selectedMeal.prevRating = String(selectedMeal.rating) + ","
                    //save it to backendless
                    
                    print("the culprit is \(selectedMeal.prevRating)")
                }
			}
			
		} else if segue.identifier == "AddItem" {
			print("Adding new meal.")
            
            let navVC = segue.destination as! UINavigationController
            let nextVC = navVC.topViewController as! MealViewController
            
            nextVC.addingNewItem = true 
            
		}
	}
	
	@IBAction func unwindToMealList(_ sender: UIStoryboardSegue) {
		
		if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
			
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				
				// Update an existing meal.
				meals[(selectedIndexPath as NSIndexPath).row] = meal
				tableView.reloadRows(at: [selectedIndexPath], with: .none)
//!!!!!!!!!!!!!!!!!!!!!!!
                
				
			} else {
				
				// Add a new meal.
				let newIndexPath = IndexPath(row: meals.count, section: 0)
				meals.append(meal)
				tableView.insertRows(at: [newIndexPath], with: .bottom)
			}
			
			if !BackendlessManager.sharedInstance.isUserLoggedIn() {
				// We're not logged in - save the meals using NSKeyedUnarchiver.
				saveMealsToArchiver()
			}
		}
        
        //refresh(sender: sender)
	}
	
	// MARK: NSCoding
	
	func saveMealsToArchiver() {
		
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: MealData.ArchiveURL.path)
		
		if !isSuccessfulSave {
			print("Failed to save meals...")
		}
	}
	
	func loadMealsFromArchiver() -> [MealData]? {
		
		return NSKeyedUnarchiver.unarchiveObject(withFile: MealData.ArchiveURL.path) as? [MealData]
	}
	
	// MARK: Logout Button
	
//	var refreshAlert = UIAlertController(title: "Refresh", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
//	
//	refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
//	print("Handle Ok logic here")
//	}))
//	
//	refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
//	print("Handle Cancel Logic here")
//	}))
//	
//	presentViewController(refreshAlert, animated: true, completion: nil)
	@IBAction func logoutBtn(_ sender: UIBarButtonItem) {
		
		let alert = UIAlertController(title: "Logout", message: "logout now?", preferredStyle: UIAlertControllerStyle.alert)
		
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
			BackendlessManager.sharedInstance.logoutUser(
				
				completion: {
					self.performSegue(withIdentifier: "gotoLoginFromMenu", sender: sender)
				},
				
				error: { message in
					print("User failed to log out: \(message)")
			})
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
			print("Handle Ok logic here")
		}))
		
//		BackendlessManager.sharedInstance.logoutUser(
//			
//			completion: {
//				self.performSegue(withIdentifier: "gotoLoginFromMenu", sender: sender)
//			},
//			
//			error: { message in
//				print("User failed to log out: \(message)")
//		})

		self.present(alert, animated: true, completion: nil)
		
		print( "logoutBtn called!" )
		

	}
    
    

}
