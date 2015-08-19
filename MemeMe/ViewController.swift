//
//  ViewController.swift
//  MemeMe
//
//  Created by Casey Arnold on 8/12/15.
//  Copyright (c) 2015 Casey Arnold. All rights reserved.
//

import UIKit
import MobileCoreServices


class ViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //Locking Screen in Portrait View
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    
    @IBOutlet weak var topToolbar: UIToolbar!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var textTop: UITextField!
    
    @IBOutlet weak var textBottom: UITextField!
    
    var memedImage : UIImage!
    
    var meme : Meme!
    
    var newMedia: Bool?

    
    let memeTextAttributes = [
        
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -2.0
    ]
    

    //No Camera on the iPhone / iPad
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera!", message: "This Apple device has no camera!", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func useCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        
        let imagePicker = UIImagePickerController()
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.mediaTypes = [kUTTypeImage as NSString]
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
        newMedia = true
        
        }
            
        else {
            
        noCamera()
            
        }
    }
    
    
    @IBAction func useCameraRoll(sender: AnyObject) {
            
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            
        let imagePicker = UIImagePickerController()
        imageView.contentMode = UIViewContentMode.ScaleToFill
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as NSString]
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
            
        newMedia = false
            
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
            self.dismissViewControllerAnimated(true, completion: nil)
        
            if mediaType.isEqualToString(kUTTypeImage as! String) {
                
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            imageView.image = image
                
            }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        
        self.subscribeToKeyboardNotifications()
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if textBottom.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    
        //Hiding Keyboard
    func keyboardWillHide(notification: NSNotification) {
        if textBottom.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
        
    }
    

    // Dismisses the keyboard when you press return (the bottom right key)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
//    User touches the screen the keyboard will disappear when that happens...Future Upgrade.
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.view.endEditing(true)
//    }
    
    
    // Describe the keyboard's notification subscribtion
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    

     //Unsubscribe
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    // Describe the keyboard's notification un-subscribtion
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
     override func viewDidLoad() {
        
        //Clearing text when editing:
        
        textTop.clearsOnBeginEditing = true
        textBottom.clearsOnBeginEditing = true
        
        super.viewDidLoad()
        
        func textFieldShouldReturn(textField: UITextField) -> Bool {
            
            textField.resignFirstResponder()
            return true;
            
        }
        
        textTop.text = "TOP"
        textTop.defaultTextAttributes = memeTextAttributes
        textTop.textAlignment = NSTextAlignment.Center
        textTop.delegate = self
        
        textBottom.text = "BOTTOM"
        textBottom.defaultTextAttributes = memeTextAttributes
        textBottom.textAlignment = NSTextAlignment.Center
        textBottom.delegate = self
        
    }
    
    
// Don't clear the text upon editing after the first time:

func textFieldDidBeginEditing(textField: UITextField) {
    textField.clearsOnBeginEditing = false
}

    struct Meme {
        var textTop:String?
        var textBottom:String?
        var originalImage:UIImage?
        var memedImage:UIImage!
    }
    
    
    func save() {
        
        //Create the meme
        var meme = Meme(textTop: textTop.text!, textBottom: textBottom.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    
    func generateMemedImage() -> UIImage {
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    
    @IBAction func saveShare(sender: AnyObject) {
        
        //Removing the Toolbars:
        self.topToolbar.hidden = true
        self.bottomToolbar.hidden = true

        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
            
            self.topToolbar.hidden = false
        }
    }
    
    @IBAction func cancelAndReturn(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
