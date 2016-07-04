//
//  EditMemeViewController.swift
//  MemeMe
//
//  Created by martin chibwe on 7/3/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController {

	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var bottomTextField: UITextField!
	@IBOutlet weak var topTextField: UITextField!
	@IBOutlet weak var imagePickerView: UIImageView!
	var image: UIImage?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		

    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
	}
	
	
	
	

	@IBAction func actionButton(sender: AnyObject) {
	}

	@IBAction func pickAnImageFromAlbum (sender: AnyObject) {
		pickPhotoFromLibrary()
		

	}

	@IBAction func pickPhotosFromCamera(sender: AnyObject) {
		pickPhotoWithCamera()

	}
	
	
	
//		let memeTextAttributes = [
//			NSStrokeColorAttributeName : UIColor.blackColor(),
//			NSForegroundColorAttributeName : UIColor.whiteColor(),
//			NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
//			NSStrokeWidthAttributeName : -3.0
//		]
	
	func setTopAndBottomTextField()  {
		
		let memeTextAttributes = [
			NSStrokeColorAttributeName : UIColor.blackColor(),
			NSForegroundColorAttributeName : UIColor.whiteColor(),
			NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
			NSStrokeWidthAttributeName : -3.0
		]
		
		
		topTextField.backgroundColor = UIColor.clearColor()
		bottomTextField.backgroundColor = UIColor.clearColor()
		topTextField.defaultTextAttributes = memeTextAttributes
		
		
		bottomTextField.defaultTextAttributes = memeTextAttributes
		topTextField.textAlignment = .Center
		bottomTextField.textAlignment = .Center
		topTextField.delegate = self
		bottomTextField.delegate = self
	}
	

	
}


extension EditMemeViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func pickPhotoWithCamera() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .Camera
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		presentViewController(imagePicker, animated: true, completion: nil)
	}

	

	
	func pickPhotoFromLibrary() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .PhotoLibrary
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController) { dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		image = info[UIImagePickerControllerEditedImage] as? UIImage
		if image != nil {
			
			imagePickerView.image = image
			
		}
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	

}

extension EditMemeViewController: UITextFieldDelegate{
	
	
//	let memeTextAttributes = [
//		NSStrokeColorAttributeName : UIColor.blackColor(),
//		NSForegroundColorAttributeName : UIColor.whiteColor(),
//		NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
//		NSStrokeWidthAttributeName : -3.0
//	]
}


