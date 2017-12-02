//
//  ViewController.swift
//  MemeMe_1
//
//  Created by Apple on 12/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    var topText: UITextField!
    var bottomText: UITextField!
    
    let memeTextAttributes: [String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -1.0]
    
    ///View delegates
    
    override func viewWillAppear(_ animated: Bool) {
        //Enable camera button only if camera is available in the device
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        //Subscribe to keyboard notification
        subscribeToKeyboardNotification()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the screen width and height, to be used for positioning textview
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        //Disable share button initially
        shareButton.isEnabled = false
        
        //Create top text field and add to view
        topText = UITextField(frame: CGRect(x: screenWidth/2 - 100, y: 150, width: 200, height: 50))
        topText = configureTextView(textField: topText, text: "TOP", tag: 1)
        
        //Create bottom text field and add to view
        bottomText = UITextField(frame: CGRect(x: screenWidth/2 - 100, y: screenHeight - 150 - 44, width: 200, height: 50))
        bottomText = configureTextView(textField: bottomText, text: "BOTTOM", tag: 2)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //Position text view when in landscape and portrait mode
        if UIDevice.current.orientation.isLandscape{
            topText.frame = CGRect(x: size.width/2 - 100, y: 50, width: 200, height: 50)
            bottomText.frame = CGRect(x: size.width/2 - 100, y: size.height - 50 - 32, width: 200, height: 50)
        }else{
            topText.frame = CGRect(x: size.width/2 - 100, y: 150, width: 200, height: 50)
            bottomText.frame = CGRect(x: size.width/2 - 100, y: size.height - 150 - 44, width: 200, height: 50)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    ///Text field delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Set text view to empty when editing
        if (textField.tag == 1 && textField.text == "TOP") || (textField.tag == 2 && textField.text == "BOTTOM"){
            textField.text = ""
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //End editing on click of return key
        view.endEditing(true)
        return true
    }
    
    ///Image picker delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            
            //Enable share button only when the image is selected
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    ///IBAction

    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        configureImagePicker(imagePickerSource: .savedPhotosAlbum)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        configureImagePicker(imagePickerSource: .camera)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        var memeImage = UIImage()
        let shareActivityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        self.present(shareActivityController, animated: true, completion: nil)
        
        shareActivityController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            
            if !completed {
                return
            }
            memeImage = self.save()
        }
    }
    
    
    ///Methods
    
    func configureTextView( textField: UITextField, text: String, tag: Int) -> UITextField {
        let textField = textField
        textField.text = text
        textField.tag = tag
        textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self as UITextFieldDelegate
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        self.view.addSubview(textField)
        return textField
    }
    
    func configureImagePicker(imagePickerSource: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = imagePickerSource
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func hideToolbar(_ hidden: Bool) {
        bottomToolBar.isHidden = hidden
        topToolBar.isHidden = hidden
    }
    
    //Subscribe to keyboard notification
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    //Unsubscribe from keyboard notification
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        //Shift view to accomodate keyboard when bottom text is being edited
        if bottomText.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        //Move view to original position when keyboard is hidden
        view.frame.origin.y = 0
    }
    
    //Get keyboard height
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //Save Meme
    func save() -> UIImage {
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        return meme.memedImage
    }
    
    //Generate meme
    func generateMemedImage() -> UIImage {
        //Hide bottomToolBar and navbar
        hideToolbar(true)
        
        //Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        //Show bottomToolBar and navbar
        hideToolbar(false)
        return memedImage
    }
}

