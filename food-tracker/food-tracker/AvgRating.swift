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
    
    var currentRating: Double = 0
    var avgRating: Double = 0
    
    //function that calculates average rating (using star system..round up or down to the nearest half-star)
    func calcAvgRating(_ mealRating: Double, pastRating: String?) -> Double {
        
        currentRating = mealRating
        var pastR: [Double] = [6.0]
        var count = 0
        var tempAvg: Double = 0.00
        var sum: Double = 0.0
        var tempArray: [Double] = []
        
        //set pastR to prevRating if its != nil
        if pastRating != nil && pastRating != "0.0"{
            
            //splitting up ratings into seperate numbers(but in quotes)
            let prevRatArray = pastRating!.components(separatedBy: ",")
            print("prevRatArray is \(prevRatArray)..but we pulled it from PastRating which is \(pastRating)") //delete after debugging
            
            
            //this loop will change strings into Doubles
            //!!!***WE must clean up duplicates here!!!!!
            for i in prevRatArray{
                if (i != "") && (i != " ") {
                    tempArray.append(Double(i)!)
                }
         
            }
            pastR = tempArray
        } else {
            pastR = [6.0]
        }

        
        
            if (pastR == [6.0]) {
                sum = currentRating
                tempAvg = sum
            } else {
                // sum = currentRating + pastR s'
                
                for i in pastR {
                    sum = sum + i
                    count = count + 1
                }
                sum = sum + currentRating
                count = count + 1 //for currentRating
                print("pastR is \(pastR)")
                print("sum is \(sum)")     //delete after debugging
                print("in avg area the count is \(count)")
                tempAvg = sum / Double(count)
                print("the tempAvg is \(tempAvg)") //delete after debugging
            }
       
        
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
        print("the final avg for \(mealRating) is \(avgRating)..the tempAvg is \(tempAvg)")
        return avgRating
    }
    

    func testCalcAvg(testRating: Double, testPrevRating: String) -> Double {
        
        var average: Double = 0.0   //this will be the final average
        let rating = testRating     //this is the current rating
        var pastRatings: [Double] = []  // this will be all the past ratings as numbers in an array
        
        let tempArray = testPrevRating.components(separatedBy: ",") // will put all numbers as strings in an array
        
        //now put/convert all "string" numbers into doubles in proper array
        for i in tempArray{
            //this doesnt check for nil or ""
            pastRatings.append(Double(i)!)
        }
        
        var sum = 0.0
        var count = 0
        //calculate average
        for i in pastRatings{
            
            sum = sum + i
            
            count = count + 1
        }
        sum = sum + rating
        //add to count for current rating
        count = count + 1
        
        average = sum / Double(count)
        
        return average
    }
    
    
    
    
}
