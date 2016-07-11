//
//  MemeCollectionViewCell.swift
//  MemeMe
//
// Created by martin chibwe on 7/10/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit


class MemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var topLabel: UILabel?
    @IBOutlet weak var bottomLabel: UILabel?
    @IBOutlet weak var selectionImage: UIImageView?
    
    var meme: Meme? {
        didSet {
            if let meme = meme {
				imageView?.image = meme.image
                topLabel?.text = meme.topText
                bottomLabel?.text = meme.bottomText
            }
        }
    }
    

	
}
