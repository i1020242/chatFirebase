//
//  ViewController.swift
//  demoFireBase
//
//  Created by Nguyễn Minh Trí on 4/6/17.
//  Copyright © 2017 Nguyễn Minh Trí. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewController: UITableViewController {
    let HOME_CELL = "HOME_CELL"
    var messageArr = [MessageModel]()
    
    //test
    var senderDisplayName: String = "abba"
    private var message: [MessageModel] = []
    private lazy var rootRef: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let imgMess = UIImage(named: "ic_new_mess")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: imgMess, style: .plain, target: self, action: #selector(handleNewMessage))
        setupCell()
        checkIfUSerLogin()
    }
    var messagesDictionary = [String: MessageModel]()
    
    func obserMessage() {
        
        let messageChildRef = Database.database().reference().child("message")
        let messageQuery = messageChildRef.queryOrderedByKey()
        messageQuery.observe(.childAdded, with: { (snapShot) in
            if let dictionary = snapShot.value as? [String:String] {
                let message = MessageModel()
                //check text or photo
                //get all value depend on text or video
                if let id = dictionary["userLoginID"], let name = dictionary["senderName"], let userChatID = dictionary["userChatID"], let text = dictionary["text"], text.characters.count > 0 {
                    message.name               = name
                    message.text               = text
                    message.currentLogin       = id
                    message.currentChat        = userChatID
                    message.imageURL           = dictionary["avata"]
                    self.messagesDictionary[id] = message//user login chat with list user
                    self.messageArr = Array(self.messagesDictionary.values)//
                } else if let id = dictionary["userLoginID"] as String!, let userChatID = dictionary["userChatID"] as String!, let name = dictionary["senderName"] as String! {
                    message.name               = name
                    message.text               = "Send Photo"
                    message.currentLogin       = id
                    message.currentChat        = userChatID
                    message.imageURL           = dictionary["avata"]
                    self.messagesDictionary[id] = message//user login chat with list user
                    self.messageArr = Array(self.messagesDictionary.values)//
                    
                }
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { (errorData) in
        }
    }
    
    func handleNewMessage() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newMessVC = storyBoard.instantiateViewController(withIdentifier: "NewMessageViewController") as! NewMessageViewController
        newMessVC.homeVC = self
        let naviVC = UINavigationController(rootViewController: newMessVC)
        present(naviVC, animated: true, completion: nil)
    }
    
    func checkIfUSerLogin() {
        
        if Auth.auth().currentUser == nil {
            handleLogout()
        } else {
            setupTitleview()
        }
        
    }
    
    func setupTitleview() {
        self.navigationController?.navigationBar.topItem?.title = "Message"

        
    }
    
    func handleLogout() {
        
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            showActivityIndicator()
            let ref = Database.database().reference(fromURL: "https://demofirebase-e648c.firebaseio.com/")
            let userReference = ref.child("users").child(uid!)
            let value = ["online":"false"]
            userReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print("Error save db")
                    return
                }
                print("Save data successfully")
                //self.dismiss(animated: true, completion: nil)
            })
            do {
                try Auth.auth().signOut()
                print("Logout success")
                stopActivityIndicator()
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let logInVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
                present(logInVC, animated: true, completion: nil)
            } catch let err {
                print(err)
            }
        }
        //self.dismiss(animated: true, completion: nil)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let logInVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
        present(logInVC, animated: true, completion: nil)
    }
    
    func setupCell(){
        self.tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: HOME_CELL)
        
    }
    
    func showChatLog(user:UserModel){
        let chatlogVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatlogVC.user = user
        navigationController?.pushViewController(chatlogVC, animated: true)
    }
    
    func showChatView(user:UserModel){
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let chatView = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatView.senderDisplayName = user.name
        chatView.userTest = user
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    
    func showAnonymousChatView(user:UserModel){
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let anochatView = storyBoard.instantiateViewController(withIdentifier: "AnonymousViewController") as! AnonymousViewController
        anochatView.senderDisplayName = user.name
        //send userInfo chat view
        anochatView.userTest = user
        present(anochatView, animated: true, completion: nil)
    }
    
    //MARK: TableView Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HOME_CELL, for: indexPath) as! HomeTableViewCell
        let message = messageArr[indexPath.row]
        cell.imgAvata.layer.masksToBounds = true
        cell.imgAvata.layer.cornerRadius = cell.imgAvata.frame.height/2
        cell.imgAvata.contentMode = .scaleAspectFill
        if let imgAvata = message.imageURL {
            let url = URL(string: imgAvata)
            cell.imgAvata.kf.setImage(with: url)
        }
        
        
        cell.txtName.text = message.name
        cell.txtText.text = message.text
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    /*
     Show customized activity indicator,
     actually add activity indicator to passing view
     
     @param uiView - add activity indicator to this view
     */
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }

}

