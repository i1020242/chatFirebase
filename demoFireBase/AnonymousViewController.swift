//
//  ChatViewController.swift
//  demoFireBase
//
//  Created by Nguyễn Minh Trí on 4/27/17.
//  Copyright © 2017 Nguyễn Minh Trí. All rights reserved.
//
// senderID : ID user login
import UIKit
import JSQMessagesViewController
import Firebase
import Photos
import Kingfisher

class AnonymousViewController: JSQMessagesViewController {
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    private var messageRef: DatabaseReference = Database.database().reference().child("messageAnonymous")
    //get my avata
    let abc = UserDefaults.standard.object(forKey: "myImage")
    //user is typing
    private var localTyping = false
    var isTyping:Bool{
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    private var userIsTypingRef:DatabaseReference = Database.database().reference().child("userTyping")
    private lazy var userTypingQuery = Database.database().reference().child("userTyping").queryOrderedByValue().queryEqual(toValue: true)
    
    //end
    
    var messageOfUser: MessageModel? {
        didSet {
            title = messageOfUser?.name
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    //test user typing
    func observeTyping() {
        let typingIndicatorRef = Database.database().reference().child("userTyping").child(self.senderId)
        userIsTypingRef = typingIndicatorRef
        userIsTypingRef.onDisconnectRemoveValue()
        userTypingQuery.observe(.value) { (data: DataSnapshot) in
            
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    var userTest:UserModel?
    private var messages: [JSQMessage] = []
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var storageImageRef: StorageReference = Storage.storage().reference().child("imageFolderAnonymous")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = Auth.auth().currentUser?.uid
        observeMessages()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
        addButton()
        title = userTest?.name
        setupBtnClose()
    }
    
    func setupBtnClose(){
        let btnClose = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let img : UIImage? = UIImage(named: "ic_close")
        btnClose.setBackgroundImage(img, for: .normal)
        
        btnClose.layer.cornerRadius = btnClose.frame.size.width/2
        btnClose.layer.masksToBounds = false
        view.addSubview(btnClose)
        btnClose.addTarget(self, action: #selector(closeView), for: .touchUpInside)
    }
    
    func closeView(){
        dismiss(animated: true) {
            let refRemove = self.messageRef
            refRemove.removeValue { (errorRemove, ref) in
                if errorRemove != nil {
                    print("error")
                } else {
                    print("Logout successful")
                }
            }
            
            self.storageImageRef.delete(completion: { (errorStorage) in
                if errorStorage != nil {
                    print("error")
                } else {
                    print("Logout successful")
                }
            })
        }
    }

    
    func addButton(){
        
        let height = self.inputToolbar.contentView.leftBarButtonContainerView.frame.size.height;
        let image = UIImage(named: "ic_attachment")
        let btnSmile = UIButton(type: .custom)
        btnSmile.setImage(image, for: .normal)
        btnSmile.addTarget(self, action: #selector(actionAttactmentTouch), for: .touchUpInside)
        btnSmile.frame = CGRect(x: 0, y: 0, width: 25, height: height)
        
        let imageA = UIImage(named: "ic_smile")
        let btnAttachment = UIButton(type: .custom)
        btnAttachment.setImage(imageA, for: .normal)
        btnAttachment.frame = CGRect(x: 25, y: 0, width: 25, height: height)
        
        self.inputToolbar.contentView.leftBarButtonItemWidth = 55;
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(btnSmile)
        inputToolbar.contentView.leftBarButtonContainerView.addSubview(btnAttachment)
        inputToolbar.contentView.leftBarButtonItem.isHidden = true
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
    }
    
    func actionAttactmentTouch(){
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    // MARK : Setting Up the Data Source and Delegate
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        let userChatAvataURL = URL(string: (userTest?.image)!)//img user to chat
        
        let myAvataURL = URL(string: abc as! String)
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
            cell.avatarImageView.kf.setImage(with: myAvataURL)
        } else {
            cell.textView?.textColor = UIColor.black
            cell.avatarImageView.kf.setImage(with: userChatAvataURL)
        }
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let currentUserToChat = userTest?.id
        let currentUserLogin = Auth.auth().currentUser?.uid
        let itemRefcurrentUserLogin = messageRef.childByAutoId()
        let timeSend = formatDatetoString()
        let messageItemA = [ // 2
            "userLoginID": currentUserLogin,//user login
            "senderName": senderDisplayName,//user to chat
            "userChatID" : currentUserToChat,
            "text": text!,
            "date":timeSend,
            "avata":userTest?.image
        ]
        
        itemRefcurrentUserLogin.setValue(messageItemA)
        finishSendingMessage()
        isTyping = false
    }
    
    func sendPhotoMessage() -> (String?) {
        
        let currentUserToChat = userTest?.id
        let itemRefcurrentUserLogin = messageRef.childByAutoId()
        let messageItem = [
            "photoURL": "NOTSET",
            "userLoginID": senderId!,
            "userChatID" : currentUserToChat,
            "senderName": senderDisplayName,
            ]
        
        itemRefcurrentUserLogin.setValue(messageItem)
        
        finishSendingMessage()
        return (itemRefcurrentUserLogin.key)
    }
    
    func formatDatetoString()->String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "HH:mm:ss dd-MMM-yyyy"
        let myStringafd = formatter.string(from: yourDate!)
        return myStringafd
    }
    
    func setImageUserChatURL(_ url: String, forPhotoMessageWithKey key: String) {
        
        let currentUserToChat = userTest?.id
        let itemRefcurrentUserToChat = messageRef.child(currentUserToChat!).child(key)
        itemRefcurrentUserToChat.updateChildValues(["photoURL":url])
    }
    
    func setImageUserLoginURL(_ url: String, forPhotoMessageWithKey key: String) {
        
        let itemRefcurrentUserLogin = messageRef.child(key)
        itemRefcurrentUserLogin.updateChildValues(["photoURL": url])
    }
    
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    let loginID = Auth.auth().currentUser?.uid
    
    private func observeMessages() {
        let messageChildRef = messageRef
        let messageQuery = messageChildRef.queryOrderedByKey()
        //obser change
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! [String:Any]
            if let id = messageData["userLoginID"] as! String!, let name = messageData["senderName"] as! String!, let userChatID = messageData["userChatID"] as! String!, let text = messageData["text"] as! String!, text.characters.count > 0 {
                if self.loginID == id  && userChatID == self.userTest?.id{
                    self.addTextMessage(withId:id, name: name, text: text)
                } else if id == self.userTest?.id  && userChatID == self.loginID {
                    self.addTextMessage(withId:id, name: name, text: text)
                }
                
                self.finishReceivingMessage()
            } else if let id = messageData["userLoginID"] as! String!, let userChatID = messageData["userChatID"] as! String!, let photoURL = messageData["photoURL"] as! String! {
                if self.loginID == id  && userChatID == self.userTest?.id{
                    let mediaItem : JSQPhotoMediaItem
                    if id == self.senderId {
                        mediaItem = JSQPhotoMediaItem(maskAsOutgoing: true)
                    } else {
                        mediaItem = JSQPhotoMediaItem(maskAsOutgoing: false)
                    }
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    if photoURL .contains("https://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                    
                } else if id == self.userTest?.id  && userChatID == self.loginID {
                    let mediaItem : JSQPhotoMediaItem
                    if id == self.senderId {
                        mediaItem = JSQPhotoMediaItem(maskAsOutgoing: true)
                    } else {
                        mediaItem = JSQPhotoMediaItem(maskAsOutgoing: false)
                    }
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    if photoURL .contains("https://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
                
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        updatedMessageRefHandle = messageQuery.observe(.childChanged, with: { (snapshot) in
            
            
            let key = snapshot.key
            let messageData = snapshot.value as! [String:Any]
            if let photoURL = messageData["photoURL"] as! String! { // 2
                // The photo has been updated.
                let mediaItem = self.photoMessageMap[key] // 3
                self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem!, clearsPhotoMessageMapOnSuccessForKey: key) // 4
            }
        })
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        
        let photourlTest = URL(string: photoURL)
        KingfisherManager.shared.retrieveImage(with: photourlTest!, options: nil, progressBlock: nil) { (imageTest, errorTest, urlCache, urlImg) in
            mediaItem.image = imageTest
            self.collectionView.reloadData()
            guard key != nil else {
                return
            }
            self.photoMessageMap.removeValue(forKey: key!)
        }
        
    }
    
    func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        let message = JSQMessage(senderId: id, displayName: "", media: mediaItem)
        //bubble depend on current login or current want to chat
        messages.append(message!)
        if (mediaItem.image == nil) {
            photoMessageMap[key] = mediaItem
        }
        collectionView.reloadData()
    }
    
    private func addTextMessage(withId loginID: String, name: String, text: String) {
        
        let message = JSQMessage(senderId: loginID, displayName: name, text: text)
        messages.append(message!)
        self.collectionView .reloadData()
        
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
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
    
    //test
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
        print(textView.text != "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isTyping = false
    }
}

extension AnonymousViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            let keyLogin = sendPhotoMessage()
            asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                
                let imageFileURL = contentEditingInput?.fullSizeImageURL
                // WARNING : TODO
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy.hh.mm.ss"
                let result = formatter.string(from: date)
                
                let path = result.appending(photoReferenceUrl.lastPathComponent)
                let dataIMG = NSData(contentsOf: imageFileURL!)
                let myPic = UIImage(data: dataIMG! as Data)
                let mythumb = myPic?.resizedEX(withPercentage: 0.1)
                let dataUpload = UIImagePNGRepresentation(mythumb!)
                //upload image
                self.storageImageRef.child(path).putData(dataUpload!, metadata: nil, completion: { (metadata, errordata) in
                    //save image into firebase db
                    self.setImageUserLoginURL((metadata?.downloadURL()?.absoluteString)!, forPhotoMessageWithKey: keyLogin!)
                })
            })
        } else {
            // Handle picking a Photo from the Camera - TODO
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}












