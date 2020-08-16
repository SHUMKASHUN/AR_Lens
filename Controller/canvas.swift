//
//  canvas.swift
//  SpokenWord
//
//  Created by KASHUN SHUM on 16/8/2020.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

import UIKit

class Canvas: UIView{

	
	
	override func draw(_ rect: CGRect) {
	
		super.draw(rect)
		guard let context = UIGraphicsGetCurrentContext() else {return }
		//First Horizental Line
		var firstHoriLine = [CGPoint]()
		firstHoriLine.append(CGPoint(x: 0.0, y: 100.0))
		firstHoriLine.append(CGPoint(x: 400.0, y: 100.0))
		//Second Horizental Line
		var secondHoriLine = [CGPoint]()
		secondHoriLine.append(CGPoint(x: 0.0, y: 200.0))
		secondHoriLine.append(CGPoint(x: 400.0, y: 200.0))
		//Third Horizental Line
		var thirdHoriLine = [CGPoint]()
		thirdHoriLine.append(CGPoint(x: 0.0, y: 300.0))
		thirdHoriLine.append(CGPoint(x: 400.0, y: 300.0))
		//Fourth Horizental Line
		var fourthHoriLine = [CGPoint]()
		fourthHoriLine.append(CGPoint(x: 0.0, y: 400.0))
		fourthHoriLine.append(CGPoint(x: 400.0, y: 400.0))
		//Fifth Horizental Line
		var fifthHoriLine = [CGPoint]()
		fifthHoriLine.append(CGPoint(x: 0.0, y: 500.0))
		fifthHoriLine.append(CGPoint(x: 400.0, y: 500.0))
		//First Vertical Line
		var firstVertiLine = [CGPoint]()
		firstVertiLine.append(CGPoint(x: 124.0, y: 0.0))
		firstVertiLine.append(CGPoint(x: 124.0, y: 600.0))
		//Second Vertical Line
		var secondVertiLine = [CGPoint]()
		secondVertiLine.append(CGPoint(x: 248.0, y: 0.0))
		secondVertiLine.append(CGPoint(x: 248.0, y: 600.0))
		//Draw the Grid
		context.addLines(between: firstHoriLine)
		context.addLines(between: secondHoriLine)
		context.addLines(between: thirdHoriLine)
		context.addLines(between: fourthHoriLine)
		context.addLines(between: fifthHoriLine)
		context.addLines(between: firstVertiLine)
		context.addLines(between: secondVertiLine)

		
		context.strokePath()
	}
}
