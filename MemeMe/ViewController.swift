//
//  ViewController.swift
//  MemeMe
//
//  Created by Roberta Voulon on 2015-12-06.
//  Copyright © 2015 Roberta Voulon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIBarButtonItem!

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
        topTextField.delegate = self
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        
        // Configure bottom text field
        bottomTextField.text = "BOTTOM"
        bottomTextField.delegate = self
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = NSTextAlignment.Center

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
        _ = Meme(upperText: topTextField.text!, bottomText: bottomTextField.text!, sourceImage: imagePickerView.image!, memedImage: memedImage!)
        
    }
    
    func generateMemedImage() -> UIImage {
        
        /* hide the toolbar before we take the snapshot
         / The way I've done it, I don't actually need to hide the toolbar.
         / Here is that code anyway :)
        */
//        self.navigationController?.setToolbarHidden(true, animated: false)
        
        // Render the scroll view to an image
        var aRect: CGRect = scrollView.frame
        let toolbarHeight = navigationController!.toolbar.frame.height
        aRect.size.height -= toolbarHeight
        
        UIGraphicsBeginImageContextWithOptions(aRect.size, false, UIScreen.mainScreen().scale)
        view.drawViewHierarchyInRect(scrollView.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        /*
         / Just to complete the exercise to unhide the toolbar, but we don't 
         / actually need it.
        */
//        self.navigationController?.setToolbarHidden(false, animated: false)

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        view.endEditing(true)
        scrollView.scrollEnabled = false
    }
    
    // MARK: UIScrollViewDelegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imagePickerView
    }
    
    // MARK: IBAction methods
    
    @IBAction func pickAnImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
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
    
    @IBAction func takeAPicture(sender: AnyObject) {
        
        // Use the camera to take a picture
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
}

