//
//  food_trackerTests.swift
//  food-trackerTests
//
//  Created by Melissa Phillips on 9/15/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//
import UIKit
import XCTest
@testable import food_tracker

class food_trackerTests: XCTestCase {
    
     // MARK: FoodTracker Tests
	
	// Tests to confirm that the Meal initializer returns when no name or a negative rating is provided.
	func testMealInitialization() {
		
		// Success case.
		let potentialItem = Meal(name: "Newst meal", photo: nil, rating: 5)
		XCTAssertNotNil(potentialItem)
		
		// Failure cases.
		let noName = Meal(name: "", photo: nil, rating: 0)
		XCTAssertNil(noName, "Empty name is invalid")
		
		let badRating = Meal(name: "Really bad rating", photo: nil, rating: -1)
		XCTAssertNil(badRating)
	}
}
