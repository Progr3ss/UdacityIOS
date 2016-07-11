//
//  Meme.swift
//  MemeMe
//
//  Created by martin chibwe on 7/10/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//


import UIKit


class Meme: NSObject {
	var topText: String
	var bottomText: String
	var image: UIImage
	var memedImage: UIImage?
	var scaledAndCroppedImage: UIImage?
	
	init(topText: String, bottomText: String, image: UIImage) {
		self.topText = topText
		self.bottomText = bottomText
		self.image = image
		self.memedImage = image
	}
}