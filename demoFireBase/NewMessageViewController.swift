//
//  NewMessageViewController.swift
//  demoFireBase
//
//  Created by Nguyễn Minh Trí on 4/7/17.
//  Copyright © 2017 Nguyễn Minh Trí. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import MGSwipeTableCell

let NEW_MESS_CELL = "MESS_CELL"

class NewMessageViewController: UITableViewController {
    
    
    var users = [UserModel]()
    var homeVC:HomeTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        fetechUSer()
        setupCell()
    }
    
    func fetechUSer(){
        
        Database.database().reference().child("users").observe(.childAdded, with: { (cyberShot) in
            if let dictionary = cyberShot.value as? [String:String] {
                print(dictionary)
                let user = UserModel()
                user.id = cyberShot.key
                user.name = dictionary["name"]
                user.email = dictionary["email"]!
                user.image = dictionary["image"]!
                user.isOnline = dictionary["online"]!
                DispatchQueue.main.async {
                    let myEmail = Auth.auth().currentUser?.email
                    if user.email != myEmail {
                        self.users.append(user)
                        self.tableView.reloadData()
                    } else {//myInfo
                        UserDefaults.standard.set(user.image!, forKey: "myImage")
                    }
                    
                }
            }
        }) { (err) in
            print(err)
        }
        
    }
    
    func setupCell() {
        self.tableView.register(UINib(nibName:"NewMessageTableViewCell", bundle:nil), forCellReuseIdentifier: NEW_MESS_CELL)
        tableView.rowHeight = 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NEW_MESS_CELL, for: indexPath) as? NewMessageTableViewCell
        
        if cell == nil {
            cell = NewMessageTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: NEW_MESS_CELL);
        }
        var user = UserModel()
        user = users[indexPath.row]
        cell?.lblName.text = user.name
        cell?.lblEmail.text = user.email
        //load image Profile
        if let imgUser = user.image {
            let url = URL(string: imgUser)
            cell?.imgProfile.contentMode = .scaleAspectFit
            cell?.imgProfile.kf.setImage(with: url)
        }
        //lbl userOnline Offline
        cell?.lblUserOnline.layer.cornerRadius = (cell?.lblUserOnline.frame.size.width)!/2
        cell?.lblUserOnline.clipsToBounds = true
        if user.isOnline! == "true"{
            cell?.lblUserOnline.backgroundColor = UIColor.green
            let queueButton = MGSwipeButton(title: "Anonymous Chat", backgroundColor: UIColor.green, padding: 39, callback: { (sender) -> Bool in
                self.dismiss(animated: true) {
                    let userSelected = self.users[indexPath.row]
                    self.homeVC?.showAnonymousChatView(user: userSelected)
                }
                return true
            })
            cell?.leftButtons = [queueButton]
            cell?.leftSwipeSettings.transition = .rotate3D
        } else {
            cell?.lblUserOnline.backgroundColor = UIColor.clear
        }
        //configure left buttons
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let userSelected = self.users[indexPath.row]
            self.homeVC?.showChatView(user: userSelected)
        }
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
