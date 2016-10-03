//
//  MealData.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/15/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class MealData: NSObject, NSCoding {
	
	// MARK: Common Properties Shared by Archiver and Backendless
	
	var name: String
	var rating: Int
	var note: String?
	
	// MARK: Archiver Only Properties
	
	var photo: UIImage?
	
	// MARK: Backendless Only Properties
	
	var objectId: String?
	var photoUrl: String?
	var thumbnailUrl: String?
	
	var replacePhoto: Bool = false
	
	// MARK: Archiving Paths
 
	static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
	
	// MARK: Types
 
	struct PropertyKey {
		
		static let nameKey = "name"
		static let photoKey = "photo"
		static let ratingKey = "rating"
		static let noteKey = "note"
	}
	
//	 MARK: Initialization
 
	init?(name: String, photo: UIImage?, rating: Int, note: String) {
		
		// Initialize stored properties.
		self.name = name
		self.photo = photo
		self.rating = rating
		self.note = note
		
		super.init()
		
		// Initialization should fail if there is no name or if the rating is negative.
		if name.isEmpty || rating < 0 {
			return nil
		}
	}
	
//	 MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		
		aCoder.encode(name, forKey: PropertyKey.nameKey)
		aCoder.encode(photo, forKey: PropertyKey.photoKey)
		aCoder.encode(rating, forKey: PropertyKey.ratingKey)
		aCoder.encode(note, forKey: PropertyKey.noteKey)
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		
		let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
		
		// Because photo is an optional property of Meal, use conditional cast.
		let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
		
		let rating = aDecoder.decodeInteger(forKey: PropertyKey.ratingKey)
		
		let note = aDecoder.decodeObject(forKey: PropertyKey.noteKey) as! String
		
		// Must call designated initializer.
		self.init(name: name, photo: photo, rating: rating, note: note)
	}
}
