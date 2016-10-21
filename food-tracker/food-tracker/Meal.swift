//
//  Meal.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/21/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import Foundation

class Meal : NSObject {
    
    var ownerId: String?
	
	var objectId: String?
	var name: String?
	var photoUrl: String?
	var thumbnailUrl: String?
	var rating: Double = 0  //use to be an int
	var note: String?
    var restaurantName: String?
    var starRatings: String?
    

    var prevRating: Double?

}
