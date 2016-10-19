//
//  MealTableViewCell.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/15/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {
	
	// MARK: Properties

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var avgStarHeader: UILabel! //this doesnt change
	@IBOutlet weak var ratingControl: RatingControl!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var avgRatingLabel: UILabel!
	
    
    override func awakeFromNib() {

        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
