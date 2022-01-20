//
//  MemeEditorViewController.swift
//  Meme-App2
//
//  Created by Ronald Pineda on 13/01/22.
//


import UIKit


class MemeEditorViewController: UIViewController,  UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: Properties for Editing
    
    var topText:String! = "TOP"
    var bottomText:String! = "BOTTOM"
    var OrigImage:UIImage! = nil

    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var topTextField:UITextField!
    @IBOutlet weak var bottomTextField:UITextField!
    
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name:"HelveticaNeue-CondensedBlack",size:40)!,
        .strokeWidth:  -3.5
    ]
    
    // Delegates - centering and formatting text
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextField(self.topTextField)
        setUpTextField(self.bottomTextField)
        self.shareButton.isEnabled = false
        
    }
    
    func setUpTextField(_ textField: UITextField) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        
        
    }
    
    // Disable camera button if device doesn't have camera and when the keyboard appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardHideNotifications()
        setTextAndImage()
        }
    
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    // Choosing photo for memes from Album
    @IBAction func pickPhotoFromAlbum(_ sender: Any) {
          pickAnImageAndShow(from: .photoLibrary)
    }
    // Choosing photo for memes from Camera
    @IBAction func pickPhotoFromCamera(_ sender: Any) {
         pickAnImageAndShow(from: .camera)
    }
    
    func pickAnImageAndShow(from photoSource: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = photoSource
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // Delegate functionality of UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        self.shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.shareButton.isEnabled = false
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Shifting the view up when keyboard is displayed
    @objc func keyboardWillShow(_ notification: Notification){
        if bottomTextField.isFirstResponder {
           view.frame.origin.y = -getKeyboardHeight(notification)
        }
        
    }
    
    // subscribing to keyboard show notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // subscribing to keyboard hide notifications
    func subscribeToKeyboardHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Shifting the view back down when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    func saveMeme(_ memeImageFinished: UIImage)  {
        let meme = Meme(topText: self.topTextField.text! as NSString, bottomText: self.bottomTextField.text! as NSString, originalImage: self.imageView.image, memedImage: memeImageFinished)
        // Add it to the memes array in the Application Delegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
            
    }
    
    func hideAndShowBars(isEnabled: Bool) {
            self.topToolBar.isHidden = isEnabled
            self.bottomToolBar.isHidden = isEnabled
        }
    
    func generateMeme() -> UIImage {
            hideAndShowBars(isEnabled: true)
            UIGraphicsBeginImageContext(self.view.frame.size)
            view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
            let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            hideAndShowBars(isEnabled: false)
            return memedImage
            
        }
    
    
        
    @IBAction func shareMeme(_ sender: Any) {
        
        var memeImage: UIImage
        memeImage = generateMeme()
        let vc = UIActivityViewController(activityItems: [memeImage], applicationActivities: [])
        vc.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
                                            Bool, arrayReturnedItems: [Any]?, error: Error?) in
                                                if completed {
                                                    self.saveMeme(memeImage)
                                                    return
                                                }
                                            }
        present(vc, animated: true)
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
        
        self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
        self.imageView.image = nil
        dismiss(animated: true, completion: nil)
        
        
    }
    
    //MARK: Set selected Meme after Edit Meme is selected
    
    func  setTextAndImage() {
        self.topTextField.text = self.topText
        self.bottomTextField.text = self.bottomText
        self.imageView.image = self.OrigImage
        self.shareButton.isEnabled = true
    }
    
    
}

