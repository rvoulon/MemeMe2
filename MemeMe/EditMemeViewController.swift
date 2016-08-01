//
//  EditMemeViewController.swift
//  MemeMe
//
//  Created by Roberta Voulon on 2015-12-06.
//  Copyright © 2015 Roberta Voulon. All rights reserved.
//

import UIKit

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!

    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName : NSNumber(float: -3.0)
    ]
    
    var memedImage: UIImage?
    
    var activeField: UITextField?

    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure top text field
        topTextField.text = "TOP"
        setTextField(topTextField)
        
        // Configure bottom text field
        bottomTextField.text = "BOTTOM"
        setTextField(bottomTextField)

        // Configure the zooming bounds for the image
        // https://www.veasoftware.com/tutorials/2015/8/3/pinch-to-zoom-uiimageview-with-swift
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 6.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Only enable camera button if camera is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)

        // Only enable share button if an image has been selected
        if (imagePickerView.image == nil) {
            shareButton.enabled = false
        }
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        super.prefersStatusBarHidden()
        
        return true
    }
    
    // MARK: generate meme
    
    func save() {
        
        // Create the meme
        memedImage = generateMemedImage()
        let meme = Meme(upperText: topTextField.text!, bottomText: bottomTextField.text!, sourceImage: imagePickerView.image!, memedImage: memedImage!)
        
        // Add the meme to the memes array in the Application Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes.append(meme)
        
    }
    
    func generateMemedImage() -> UIImage {
        
        /* hide the toolbar before we take the snapshot
         / The way we've done it here, we don't actually need to hide the toolbar.
         / Here is that code anyway :)
        */
//        navigationController?.setToolbarHidden(true, animated: false)
        
        // Lower the bottom text field so that it matches the margin of the top text field
        bottomTextFieldConstraint.constant = 8
        // Render the view to an image
        let aRect: CGRect = view.frame
        UIGraphicsBeginImageContextWithOptions(aRect.size, false, UIScreen.mainScreen().scale)
        view.drawViewHierarchyInRect(aRect, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Put the bottom text field back where it was, just above the toolbar.
        bottomTextFieldConstraint.constant = 52
        
        /*
         / Just to complete the exercise to unhide the toolbar, but we don't 
         / actually need it.
        */
//        navigationController?.setToolbarHidden(false, animated: false)

        return memedImage
    }
        
    // MARK: UITextFieldDelegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        activeField = textField
        
        if textField == topTextField {
            if textField.text == "TOP" {
                textField.text = ""
            }
        } else if textField == bottomTextField {
            if textField.text == "BOTTOM" {
                textField.text = ""
            }
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            if textField == topTextField {
                textField.text = "TOP"
            } else if textField == bottomTextField {
                textField.text = "BOTTOM"
            }
        }
        
        activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Keyboard methods
    
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMemeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMemeViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        /*
         / Note for reviewer: I'm using a scrollview to move the view up with
         / the height of the keyboard if we are editing the bottomTextField,
         / as recommended by Apple:
         / http://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field?lq=1
         / https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
        */
        
        // When the keyboard shows, we use an inset that has the size of the
        // keyboard, and we'll scroll the scrollview up appropriately.
        scrollView.scrollEnabled = true
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = view.frame
        aRect.size.height -= keyboardSize!.height
        if let _ = activeField {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin)) {
                scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        // Fix the bottom text to the bottom margin, since there's no toolbar
        // to consider while we're editing the text
        bottomTextFieldConstraint.constant = 8
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        view.endEditing(true)
        scrollView.scrollEnabled = false
        
        // Make the bottom text show just above the toolbar again
        bottomTextFieldConstraint.constant = 52

    }
    
    // MARK: UIScrollViewDelegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imagePickerView
    }
    
    // MARK: Helper methods

    func setTextField(textField: UITextField) {

        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
        
    }
    
    func setImagePickerController(sourceType: UIImagePickerControllerSourceType) {

        // Set the image picker controller before presenting it to the user
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)

    }
    
    // MARK: IBAction methods
    
    @IBAction func cancelAndDismiss(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func pickAnImage(sender: AnyObject) {
        
        // Select an image from the photo library
        let sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        setImagePickerController(sourceType)
    }
    
    @IBAction func takeAPicture(sender: AnyObject) {
        
        // Use the camera to take a picture
        let sourceType = UIImagePickerControllerSourceType.Camera
        setImagePickerController(sourceType)

    }

    @IBAction func shareMeme(sender: AnyObject) {
        
        // generate a memed image and pass it to an activity view controller
        memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)

        // completion handler for activity view controller:
        // save the meme and dismiss the view controller when done.
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        presentViewController(activityVC, animated: true, completion: nil)
    }
    
}

