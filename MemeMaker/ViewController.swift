//
//  ViewController.swift
//  VoiceFilter
//
//  Created by Hector Montero on 12/29/16.
//  Copyright © 2016 Hector Montero. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var isGeneratingMeme: Bool = false
    
    @IBOutlet weak var shareButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cameraButtonItem: UIBarButtonItem!
    @IBOutlet weak var galleryButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        cameraButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        galleryButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.white,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: 0
            ] as [String : Any]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        topTextField.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: memeTextAttributes)
        topTextField.placeholder = "TOP"
        topTextField.delegate = self
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: memeTextAttributes)
        bottomTextField.placeholder = "BOTTOM"
        bottomTextField.delegate = self
        
        galleryButtonItem.action = #selector(getImageFromGallery)
        cameraButtonItem.action = #selector(getImageFromCamera)
        
        setEnabledGeneratingMeme(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.suscribeToKeyNotafications()    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()    }
    
    @IBAction func cancelPickingPicture(_ sender: UIBarButtonItem!) {
        imageView.image = nil
        
        setEnabledGeneratingMeme(false)
    }
    
    ////////////////////////////////////////////
    //Image Control
    ////////////////////////////////////////////
    @IBAction func getImageFromGallery(_ sender: UIBarButtonItem!) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        
        cancelButtonItem.isEnabled = true
    }
    
    @IBAction func getImageFromCamera(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        
        cancelButtonItem.isEnabled = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("imagePickerController")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            setEnabledGeneratingMeme(true)
        } else {
            print("Error unwrapping image")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////////////////
    //Meme functions
    ////////////////////////////////////////////
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(activityItems: [takeScreenshot()], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
        self.present(activityViewController, animated: true, completion: nil)    }
    
    @IBAction func saveMeme(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            UIImageWriteToSavedPhotosAlbum(self.takeScreenshot(), nil, #selector(self.showSaveMemeConfirmation), nil)
        }
    }
    
    func showSaveMemeConfirmation() {
        showSimpleAlertMessage("CONFIRMATION", "Meme has been saved")
    }
    
    func showSimpleAlertMessage(_ title: String, _ message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func takeScreenshot() -> UIImage{
//        self.navigationController?.setToolbarHidden(true, animated: false)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //self.navigationController?.setToolbarHidden(false, animated: false)
        
        return memedImage
    }
    
    ///////////////////////////////////////////
    //Keyboard notifications
    ////////////////////////////////////////////
    func keyboardWillShow(notification: NSNotification) {
        if self.bottomTextField.isEditing {
            self.bottomTextField.frame.origin.y -= ((notification.userInfo! as NSDictionary)[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
//    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
//        print("getKeyboardHeight")
//        let userInfo = notification.userInfo
//        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue //ofCGRect
//        return keyboardSize.cgRectValue.height
//    }
    
    func suscribeToKeyNotafications() {        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setEnabledGeneratingMeme(_ isEnabled: Bool) {
        print("setEnabledGeneratingMeme isEnabled: \(isEnabled)")
        isGeneratingMeme = isEnabled
        self.topTextField.isHidden = !isEnabled
        self.topTextField.isEnabled = isEnabled
        self.bottomTextField.isHidden = !isEnabled
        self.bottomTextField.isEnabled = isEnabled
        
        self.cancelButtonItem.isEnabled = isEnabled
        self.shareButtonItem.isEnabled = isEnabled
        self.saveButtonItem.isEnabled = isEnabled
        
        self.toolbar.isHidden = isEnabled
    }
}

