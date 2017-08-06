//
//  LogoutViewController.swift
//  demoFireBase
//
//  Created by Nguyễn Minh Trí on 4/6/17.
//  Copyright © 2017 Nguyễn Minh Trí. All rights reserved.
//

import UIKit
import Firebase

let SEG_SELECTED_LOGIN = 0
let SEG_SELECTED_REGISTER = 1

class LoginViewController: BaseViewController {
    
    
    @IBOutlet weak var imgAvata: UIImageView!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var segLogin: UISegmentedControl!
    @IBOutlet weak var btnContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r:61, g:91, b: 151)
        btnRegister.addTarget(self, action: #selector(handleBtnTouch), for: .touchUpInside)
        btnRegister.backgroundColor = UIColor(r:80, g:101, b:161)
        btnRegister.layer.cornerRadius = 6
        btnRegister.layer.masksToBounds = true
        segLogin.addTarget(self, action: #selector(handleSegment), for: .valueChanged)
        btnRegister.setTitle("Login", for: .normal)
        txtName.isHidden = true
        btnContraint.constant = 184+35
        segLogin.layer.cornerRadius = 5
        segLogin.layer.masksToBounds = true
        setupImgAvata()
        
    }
    
    func setupImgAvata() {
        imgAvata.image = UIImage(named: "ic_avata")
        imgAvata.contentMode = .scaleAspectFit
        imgAvata.isUserInteractionEnabled = true
        let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singletap))
        singleTap.numberOfTapsRequired = 1
        imgAvata.addGestureRecognizer(singleTap)
    }
    
    func singletap(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func handleBtnTouch() {
        if segLogin.selectedSegmentIndex == SEG_SELECTED_LOGIN {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin(){
        guard let email = txtEmail.text, let password = txtPwd.text
            else {
                print("Not valid")
                return
        }
        showActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.stopActivityIndicator()
                self.cutomShowAlert(title: "Message", message: (error?.localizedDescription)!)
                return
            } else {
                self.stopActivityIndicator()
                self.dismiss(animated: true, completion: {
                    let ref = Database.database().reference(fromURL: "https://demofirebase-e648c.firebaseio.com/")
                    let userReference = ref.child("users").child((user?.uid)!)
                    let value = ["online":"true"]
                    userReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            print("Error save db")
                            return
                        }
                        print("Save data successfully")
                        
                    })
                })
            }
        })
    }
    
    func handleRegister(){
        guard let email = txtEmail.text, let password = txtPwd.text, let name = txtName.text
            else {
                print("Not valid")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err) in
            if err != nil {
                print((err?.localizedDescription)! as String)
                self.cutomShowAlert(title: "Message", message: (err?.localizedDescription)!)
                return
            }
            //upload Img
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy.hh.mm.ss"
            let result = formatter.string(from: date)
            let uploadData = UIImageJPEGRepresentation(self.imgAvata.image!, 0.1)
            let storageRef = Storage.storage().reference().child("\(result)_avata.jpeg")
            
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                if let imgProfileURL = metadata?.downloadURL()?.absoluteString {
                    //test
                    let value = ["email": email, "name":name, "image":imgProfileURL, "online":"true"]
                    self.registerUserWithUID(uid: (user?.uid)!, value: value)
                }

            })
        })
    }
    
    func registerUserWithUID(uid:String, value: [String:Any]){
        //add database firebase
        let ref = Database.database().reference(fromURL: "https://demofirebase-e648c.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
            if err != nil {
                print("Error save db")
                
                return
            }
            print("Save data successfully")
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleSegment(){
        
        let segIndex = segLogin.selectedSegmentIndex
        if segIndex == 0 {//login
            btnRegister.setTitle("Login", for: .normal)
            txtName.isHidden = true
            btnContraint.constant = 184+45
        } else if segIndex == 1 {
            btnRegister.setTitle("Register", for: .normal)
            txtName.isHidden = false
            btnContraint.constant = 184
        }
    }
}

extension UIColor {
    convenience init(r: CGFloat, g:CGFloat, b:CGFloat) {
        self.init(red:r/255, green:g/255, blue:b/255, alpha:1)
    }
}

extension LoginViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        var selectedImg:UIImage?
        if let originalImg = info["UIImagePickerControllerOriginalImage"] {
            selectedImg = originalImg as? UIImage
        } else if let editedImg = info["UIImagePickerControllerEditedImage"] {
            selectedImg = editedImg as? UIImage
        }
        imgAvata.image = selectedImg
        dismiss(animated: true, completion: nil)
    }
}
