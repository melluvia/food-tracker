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
    
    // set image on bar button item
    let img = UIImage(named: "edit-symbol")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    let img2 = UIImage(named: "exit")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    
    var leftBarButtonItem = UIBarButtonItem()
    
	// Create cache that uses NSString keys to point to UIImages.
	var imageCache = NSCache<NSString, UIImage>()
	
    var isUserLoggedIn = false
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageCache.countLimit = 50 // sets cache limit to 50 images.

        // Add support for pull-to-refresh on the table view.
        self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
		
		// sets edit button to white
		self.navigationController?.navigationBar.tintColor = UIColor.white
		
		leftBarButtonItem = UIBarButtonItem(image: img,
                                            style: UIBarButtonItemStyle.plain,
                                            target: self,
                                            action: #selector(onEditBtn(sender:)))

		self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        isUserLoggedIn = BackendlessManager.sharedInstance.isUserLoggedIn()
        
        if !isUserLoggedIn {
            
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
    }
    
    func loadSampleMeals() {

        let photo1 = UIImage(named: "meal1")!
        let meal1 = MealData(name: "Caprese Salad", photo: photo1, rating: 4, note: "A great Salad!", restaurantName: "My Kitchen!!", prevRating: "4")!
        
        let photo2 = UIImage(named: "meal2")!
        let meal2 = MealData(name: "Chicken and Potatoes", photo: photo2, rating: 5, note: "Gotta Love Chicken!", restaurantName: "My mom's house", prevRating: "5")!
        
        let photo3 = UIImage(named: "meal3")!
        let meal3 = MealData(name: "Pasta with Meatballs", photo: photo3, rating: 3, note: "Just average.", restaurantName: "Denny's", prevRating: "3")!
        
        meals += [meal1, meal2, meal3]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         isUserLoggedIn = BackendlessManager.sharedInstance.isUserLoggedIn()
    }
    
    func refresh(sender: AnyObject) {
        
        if isUserLoggedIn {
            
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
            
            leftBarButtonItem.image = img
            
            isDeleting = false
            
        } else {
            
            leftBarButtonItem.image = img2 
            
            isDeleting = true
        }
        
        if isUserLoggedIn == true {
        
            filterMealsByOwner()
        }
        
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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isUserLoggedIn == true && isDeleting == true {
            return filteredMeals.count
        }
        
        return meals.count
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Table view cells are reused and should be dequeued using a cell identifier.
		let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell", for: indexPath) as! MealTableViewCell
        
        let meal: MealData
        
        if isDeleting && isUserLoggedIn == true {
            meal = filteredMeals[indexPath.row]
        } else {
            meal = meals[indexPath.row]
        }
        
        cell.nameLabel.text = meal.name
        cell.ratingControl.rating = meal.rating
        
        if isUserLoggedIn == true {
            cell.avgRatingLabel.text = String(AvgRating.init().calcAvgRating(meal.rating, pastRating: meal.prevRating))
        } else {
            cell.avgRatingLabel.isHidden = true
            cell.avgStarHeader.isHidden = true
        }
        
        // For NSCache, if we have the cache key we put it on the cell when it gets created
        if meal.thumbnailUrl != nil && isUserLoggedIn {
            
            if imageCache.object(forKey: meal.thumbnailUrl! as NSString) != nil {
                
                // If the URL for the thumbnail is in the cache already - get the UIImage that belongs to it.
                cell.photoImageView.image = self.imageCache.object(forKey: meal.thumbnailUrl! as NSString)

            } else {
                
                cell.spinner.startAnimating()
                
                loadImageFromUrl(thumbnailUrl: meal.thumbnailUrl!,
                                 
                    completion: { data in
                        
                        // retrieved data- using it to create a UIImage for our cell's ui imageview.
                        if let image = UIImage(data: data) {
                                            
                            // Bounce back to the main thread to update the UI
                            DispatchQueue.main.async {
                                                
                                cell.photoImageView.image = image
    
                                // cache the pulled down UIImage using the URL as the key.
                                self.imageCache.setObject(image, forKey: meal.thumbnailUrl! as NSString)
                            }
                        }
                                    
                        cell.spinner.stopAnimating()
                    },
                                 
                    loadError: {
                        cell.spinner.stopAnimating()
                })
            }
            
        } else {
            cell.photoImageView.image = meal.photo
        }
        
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
    
    // Disables the swipe to delete
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if tableView.isEditing {
        
            return .delete
        }
        
        return .none
    }
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			
			if isUserLoggedIn {
				
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
                
                print("Meal deleted at :\(indexPath.row)")
                
				tableView.deleteRows(at: [indexPath], with: .fade)
                
                // Save the meals.
                saveMealsToArchiver()
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
				
			} else {
				
				// Add a new meal.
				let newIndexPath = IndexPath(row: meals.count, section: 0)
				meals.append(meal)
                
                print("indexPath row: \(newIndexPath)")
                
				tableView.insertRows(at: [newIndexPath], with: .bottom)
			}
			
			if !isUserLoggedIn {
				// We're not logged in - save the meals using NSKeyedUnarchiver.
				saveMealsToArchiver()
			}
		}
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

		self.present(alert, animated: true, completion: nil)
		
		print( "logoutBtn called!" )
	}    

}
