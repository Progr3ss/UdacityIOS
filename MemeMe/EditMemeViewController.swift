//
//  EditMemeViewController.swift
//  MemeMe
//
//  Created by martin chibwe on 7/3/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController {

	@IBOutlet weak var shareButton: UIBarButtonItem!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var bottomTextField: UITextField!
	@IBOutlet weak var topTextField: UITextField!
	@IBOutlet weak var imagePickerView: UIImageView!
	
//	@IBOutlet weak var navigationBar: UINavigationItem!
	@IBOutlet weak var navigationBar: UINavigationItem!
	@IBOutlet weak var toolBar: UIToolbar!
//	@IBOutlet weak var navigationBar: UINavigationItem!
	
	var image: UIImage?
	var memedImage = UIImage()
	var meme:Meme!
	var keyboardHidden = true
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setTopAndBottomTextField()
	
		save()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		subscribeToKeyboardNotifications()
		
		cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
		 self.navigationItem.leftBarButtonItem?.enabled = false
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
	
	
	

	@IBAction func actionButton(sender: AnyObject) {
		share()
	}

	@IBAction func pickAnImageFromAlbum (sender: AnyObject) {
		pickPhotoFromLibrary()
		

	}

	@IBAction func pickPhotosFromCamera(sender: AnyObject) {
		pickPhotoWithCamera()

	}
	
	
	
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
		dismissViewControllerAnimated(true, completion: { () -> Void in
			self.shareButton.enabled = true
		})
	}
	
	

}

extension EditMemeViewController: UITextFieldDelegate{
	
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if textField.isEqual(topTextField){
			self.unsubscribeFromKeyboardNotifications()
		}
		return true
	}
	
	
	func textFieldDidBeginEditing(textField: UITextField) {
		
		if textField.text == "TOP" || textField.text == "BOTTOM"{
			textField.text = ""
		}
		if textField.isEqual(topTextField){
			self.subscribeToKeyboardNotifications()
		}
	}

	


}
//MARK: HELPER FUNCTIONS
extension EditMemeViewController{

	
	//MARK:- KEYBOARD
	func subscribeToKeyboardNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMemeViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMemeViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name:
			UIKeyboardWillShowNotification, object: nil)
		
		
		NSNotificationCenter.defaultCenter().removeObserver(self, name:
			UIKeyboardWillHideNotification, object: nil)
	}
	
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
	
	func keyboardWillShow(notification: NSNotification) {
		if bottomTextField.editing {
			
			view.frame.origin.y -= getKeyboardHeight(notification)
			
		}
		
//		view.frame.origin.y -= getKeyboardHeight(notification)
	}
	
	func keyboardWillHide(notification: NSNotification) {
		// Only bottom
		
		if bottomTextField.editing {
		 view.frame.origin.y = 0
			

			
		}
	
	}


	func generateMemedImage() -> UIImage {

		UIApplication.sharedApplication().statusBarHidden = true
		
		UIGraphicsBeginImageContext(self.view.frame.size)
		view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
		let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		

		UIApplication.sharedApplication().statusBarHidden = false
		
		return memedImage
		

	}
	//MAKR:SAVING MEME
	func save() {
		
		func save() {
			//Create the meme
			memedImage = generateMemedImage()
			let meme = Meme(topText:topTextField.text!, bottomText: bottomTextField.text!,  image: imagePickerView.image!,  memedImage: memedImage)
			self.meme = meme
			(UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
		}
	}
	
	
	func share()  {
		save()
		//activity view
		let image = UIImage()
		let controller =  UIActivityViewController(activityItems: [image],applicationActivities: nil)

		self.presentViewController(controller, animated: true, completion: nil)
	
	}
	
	
	
	
	
}


