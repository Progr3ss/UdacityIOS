//
//  MemeTableViewCell.swift
//  MemeMe
//
//  Created by martin chibwe on 7/2/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit


class MemeTableViewCell: UITableViewCell {

    @IBOutlet weak var memeLabel: UILabel?
    @IBOutlet weak var memeImageView: UIImageView? {
        didSet {
			
            if storeColorChange {
                originallyConfiguredColor = memeImageView?.backgroundColor
            }
        }
    }
    
	
    var originallyConfiguredColor: UIColor? {
        didSet {
            storeColorChange = false
        }
    }
    
    
    private var storeColorChange = true
    
    var meme: Meme? {
        didSet {
            if let meme = meme {
                memeImageView?.image = meme.memedImage
                memeLabel?.text = "\(meme.topText) \(meme.bottomText)"
            }
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            memeImageView?.backgroundColor = originallyConfiguredColor
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            memeImageView?.backgroundColor = originallyConfiguredColor
        }
    }
}
