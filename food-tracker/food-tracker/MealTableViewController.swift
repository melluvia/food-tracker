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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use the edit button item provided by the table view controller.
		navigationItem.leftBarButtonItem = editButtonItem
		
		// Load any saved meals, otherwise load sample data.
		if let savedMeals = loadMeals() {
			
			meals += savedMeals
		} else {
			
			// Load the sample data.
			loadSampleMeals()
		}
	}
	
	func loadSampleMeals() {
		
		let photo1 = UIImage(named: "meal1")!
		let meal1 = MealData(name: "Caprese Salad", photo: photo1, rating: 4)!
		
		let photo2 = UIImage(named: "meal2")!
		let meal2 = MealData(name: "Chicken and Potatoes", photo: photo2, rating: 5)!
		
		let photo3 = UIImage(named: "meal3")!
		let meal3 = MealData(name: "Pasta with Meatballs", photo: photo3, rating: 3)!
		
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
		
		return meals.count
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Table view cells are reused and should be dequeued using a cell identifier.
		let cellIdentifier = "MealTableViewCell"
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
		
		// Fetches the appropriate meal for the data source layout.
		let meal = meals[(indexPath as NSIndexPath).row]

		cell.nameLabel.text = meal.name
		cell.photoImageView.image = meal.photo
		cell.ratingControl.rating = meal.rating

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
        if editingStyle == .delete {
			
            // Delete the row from the data source
			meals.remove(at: (indexPath as NSIndexPath).row)
			
			saveMeals()
			
            tableView.deleteRows(at: [indexPath], with: .fade)
			
        } else if editingStyle == .insert {
			
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "ShowDetail" {
			
			let mealDetailViewController = segue.destination as! MealViewController
			
			// Get the cell that generated this segue.
			if let selectedMealCell = sender as? MealTableViewCell {
				
				let indexPath = tableView.indexPath(for: selectedMealCell)!
				
				let selectedMeal = meals[(indexPath as NSIndexPath).row]
				
				mealDetailViewController.meal = selectedMeal
			}
		} else if segue.identifier == "AddItem" {
			
			print("Adding new meal.")
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
				
				tableView.insertRows(at: [newIndexPath], with: .bottom)
			}
			
			// Save the meals.
			saveMeals()
		}
	}
	
	// MARK: NSCoding
	
	// Add code here to save meals to backendless
	func saveMeals() {
		
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: MealData.ArchiveURL.path)
		
		if !isSuccessfulSave {
			print("Failed to save meals...")
		}
	}
	// Add code here to load meals from Backendless
	func loadMeals() -> [MealData]? {
		
		return NSKeyedUnarchiver.unarchiveObject(withFile: MealData.ArchiveURL.path) as? [MealData]
	}
}
