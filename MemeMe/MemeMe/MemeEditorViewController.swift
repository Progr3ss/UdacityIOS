//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by martin chibwe on 7/3/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate {
    

    private let DefaultTop = "TOP"
    private let DefaultBottom = "BOTTOM"
    private let MemeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : CGFloat(-3.0)
    ]


    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem? {
        didSet {
            shareButton?.enabled = isSharingEnabled()
        }
    }

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    
    var meme: Meme? {
        didSet {
            shareButton?.enabled = isSharingEnabled()
        }
    }

    private var viewShiftDistance: CGFloat? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        configureTextField(topTextField)
        configureTextField(bottomTextField)
        
		
        imageView = UIImageView()
        
		
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
		
        scrollView.contentSize = imageView.bounds.size
		scrollView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.addSubview(imageView)
        
	
        view.insertSubview(scrollView, belowSubview: toolbar)
		
		
		
        
        scrollView.delegate = self
        
        shareButton?.enabled = isSharingEnabled()
        
		
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemeEditorViewController.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        
		
        initializeDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplayFromModel()
        layoutImageView()
		
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
  
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
		
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
	
    func handleTap(sender: UIGestureRecognizer) {
        endTextEditing()
    }
    
    func endTextEditing() {
        topTextField?.endEditing(false)
        bottomTextField?.endEditing(false)
    }
    

    @IBAction func shareMeme(sender: UIBarButtonItem) {
        if let meme = meme {
            meme.memedImage = generateMemedImage()
            meme.scaledAndCroppedImage = generateMemedImage(true)
            if let memedImage = meme.memedImage {
                let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
				
                activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
                        if completed {
                            self.saveMeme()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                }
                presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        pickImageFromSourceType(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        pickImageFromSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func cancelEditor(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        setZoomParametersForSize(scrollView.bounds.size)
    }
    

    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollView.bounds.size)
        recenterWithScrollViewOrigin()
    }
	
    func layoutImageView() {
        imageView.sizeToFit()
        imageView.frame.origin = CGPoint(x: 0.0, y: 0.0)
        scrollView.contentSize = imageView.bounds.size
        setZoomParametersForSize(scrollView.bounds.size)
    }
    
    func recenterWithScrollViewOrigin() {

        let imageViewSize = imageView.bounds.size
        let upperLeftCornerX = (imageViewSize.width * scrollView.zoomScale) / 2.0  - scrollView.bounds.size.width / 2.0
        let upperLeftCornerY = (imageViewSize.height * scrollView.zoomScale) / 2.0 - scrollView.bounds.size.height / 2.0
        scrollView.bounds.origin = CGPoint(x: upperLeftCornerX, y: upperLeftCornerY)
    }
    

    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.editing {
            var bottomOfField: CGFloat {
                let fieldOrigin =  view.convertPoint(bottomTextField.bounds.origin, fromView: bottomTextField)
                return fieldOrigin.y + bottomTextField.bounds.height
            }
            if viewShiftDistance == nil {
                let keyboardHeight = getKeyboardHeight(notification)
                let topOfKeyboard = view.bounds.maxY - keyboardHeight
				
                if topOfKeyboard < bottomOfField {
                    viewShiftDistance = bottomOfField - topOfKeyboard
                    self.view.bounds.origin.y += viewShiftDistance!
                }
            }
            toolbar.hidden = true
        }
    }
    

    func keyboardWillHide(notification: NSNotification) {
        if let shiftDistance = viewShiftDistance {
            self.view.bounds.origin.y -= shiftDistance
            viewShiftDistance = nil
            toolbar.hidden = false
        }
    }
    
	
    private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    

    private func initializeDisplay() {
        topTextField.text = meme?.topText ?? DefaultTop
        bottomTextField.text = meme?.bottomText ?? DefaultBottom
        imageView.image = meme?.image ?? imageView.image
    }
    
	
    private func updateDisplayFromModel() {
        if let meme = self.meme {
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            imageView.image = meme.image
        }
    }
    
	
    private func updateModelFromDisplay() {
        if let topText = topTextField.text,
            bottomText = bottomTextField.text {
            if meme == nil && isMemeCreateable() {
				
                meme = Meme(topText: topText, bottomText: bottomText, image: imageView.image!)
            } else {
                meme?.topText = topText
                meme?.bottomText = bottomText
                if let image = imageView.image {
                    meme?.image = image
                }
            }
        }
    }
    

    private func configureTextField(textField: UITextField) {
        textField.delegate = self
		
        textField.defaultTextAttributes = MemeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
    }
    

    private func pickImageFromSourceType(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = sourceType
            picker.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
	
    private func setZoomParametersForSize(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height

        let minScale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale
    }

    private func generateMemedImage(hideText: Bool = false) -> UIImage {
        navigationController?.navigationBarHidden = true
        
        toolbar.hidden = true
        navbar.hidden = true
        if hideText {
            topTextField.hidden = true
            bottomTextField.hidden = true
        }
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolbar.hidden = false
        navbar.hidden = false
        if hideText {
            topTextField.hidden = false
            bottomTextField.hidden = false
        }
        
        return memedImage
    }
    
	
    private func isMemeCreateable() -> Bool {
        return topTextField.text != DefaultTop && bottomTextField.text != DefaultBottom && imageView.image != nil
    }
    

    private func isSharingEnabled() -> Bool {
        return meme != nil
    }
    

    private func saveMeme() {
        if let meme = self.meme {
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            if let index = appDelegate.memes.indexOf(meme) {
                appDelegate.memes.replaceRange(index...index, with: [meme])
            } else {
                appDelegate.memes.append(meme)
            }
            
        }
    }
    
}



extension MemeEditorViewController: UIImagePickerControllerDelegate {

	
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            layoutImageView()
            updateModelFromDisplay()
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MemeEditorViewController: UITextFieldDelegate {


    func textFieldDidBeginEditing(textField: UITextField) {
        let text = textField.text
        if text == DefaultTop || text == DefaultBottom {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateModelFromDisplay()
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(false)
        return true
    }
}


extension MemeEditorViewController: UIScrollViewDelegate {

   
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
		
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
}
