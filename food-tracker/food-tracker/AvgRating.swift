//
//  AvgRating.swift
//  food-tracker
//
//  Created by Robert Martin on 10/19/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//
// This will keep track of all ratings for each meal(class will be instantiated for each meal when a new meal is created) and will keep track of all ratings/changes as an array of ratings (so calculating average will be as simple as taking a new rating, adding it to the array, then iterating through the array to get the sum and then divide by count [avg])

import Foundation

class AvgRating {
    
//    var allRatingsArray: [Double] = [] //maybe declare in function so no need to append?
    var currentRating: Double = 0
    var avgRating: Double = 0
    
    
    
    
    
    //function that calculates average rating (using star system..round up or down to the nearest half-star)
    func calcAvgRating(_ mealRating: Double, pastRating: [Double]) -> Double {
        
        currentRating = mealRating
        let pastR = pastRating //either equal to [6.0] or array of Doubles
        var tempAvg: Double = 0.0
        
        var sum: Double = 0.0
        if (pastR == [6.0]) {
            sum = currentRating
            tempAvg = sum
        } else {
       // sum = currentRating + pastR
            for i in pastR {
                sum = sum + i
            }
            sum = sum + currentRating
            tempAvg = sum / Double(2)
        }

    //function that creates an array to store all ratings for each meal (this way we can continue to update average by tracking all previous ratings from all users) backendless stored
       
        
        //calculating avg rating based on half star system
        
        switch tempAvg {
            case 0...(0.25):
                avgRating = 0
            case (0.26)...(0.75):
                avgRating = 0.5
            case (0.75)...(1.25):
                avgRating = 1.0
            case (1.26)...(1.75):
                avgRating = 1.5
            case (1.76)...(2.25):
                avgRating = 2
            case (2.26)...(2.75):
                avgRating = 2.5
            case (2.76)...(3.25):
                avgRating = 3.0
            case (3.26)...(3.75):
                avgRating = 3.5
            case (3.76)...(4.25):
                avgRating = 4
            case (4.26)...(4.75):
                avgRating = 4.5
            case (4.76)...(5.00):
                avgRating = 5.0

        default:
            avgRating = 0
        }
        
        return avgRating
    }
    
    //function that creates an array to store all ratings for each meal (this way we can continue to update average by tracking all previous ratings from all users)  ... this function will also need a database (backendless) side..just make a backendless side
    
    
    //***create a class for changing the textfield to show average stars..not needed
    
    
    func prevRatingArray() {
        
        
        
    }
    
    
    
}
