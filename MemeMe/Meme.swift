//
//  Meme.swift
//  MemeMe
//
//  Created by martin chibwe on 7/4/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import Foundation
import UIKit

struct Meme{
	var topText:String!
	var bottomText:String!
	var image: UIImage! //Original Image
	var memedImage: UIImage! //The generated image with Top and bottom text.
	
	init(let topText:String,let bottomText:String, let image:UIImage, let memedImage:UIImage){
		self.topText = topText
		self.bottomText = bottomText
		self.image = image
		self.memedImage = memedImage
	}
	
}