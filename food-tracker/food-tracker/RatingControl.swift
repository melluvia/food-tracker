//
//  RatingControl.swift
//  food-tracker
//
//  Created by Melissa Phillips on 9/15/16.
//  Copyright © 2016 Melissa Phillips Design. All rights reserved.
//

import UIKit

class RatingControl: UIView {
	
	// MARK: Properties
	
	var rating = 0
	var ratingButtons = [UIButton]()
	
	let spacing = 5
	
	let starCount = 5

	// MARK: Initialization
	
	override func layoutSubviews() {
		
		// Set the button's width and height to a square the size of the frame's height.
		let buttonSize = Int(frame.size.height)
		
		var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
		
		// Offset each button's origin by the length of the button plus spacing.
		for (index, button) in ratingButtons.enumerate() {
			buttonFrame.origin.x = CGFloat(index * (buttonSize + starCount))
			button.frame = buttonFrame
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		for _ in 0..<starCount {
		
			let button = UIButton()
			
			button.backgroundColor = UIColor.redColor()
			
			button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
			
			ratingButtons += [button]
				
			addSubview(button)
		}
		
	}
	
	override func intrinsicContentSize() -> CGSize {
		
		let buttonSize = Int(frame.size.height)
		
		let width = (buttonSize * starCount) + (spacing * (starCount - 1))
		
		return CGSize(width: width, height: buttonSize)
	}
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

	// MARK: Button Action
	func ratingButtonTapped(button: UIButton) {
		print("Button pressed 👍")
	}
}
