//
//  CreateGroupVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 05/03/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class CreateGroupVC: UIViewController {

    @IBOutlet private var avatar: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var commentField: UITextField!
    @IBOutlet var createBtn: UIButton!


    private let socket = WebSocketManager.shard
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func thePageShow() {
        self.socket.delegate = self
    }

    @IBAction func clickCreateBtn(_ sender: Any) {


        guard let name = self.nameTextField.text, name != "" else {
            self.noticeAlert(title: "Error", message: "Please fill in group name", isPop: false)
            return
        }

        guard let avatar = self.avatar.image else {
            self.noticeAlert(title: "Error", message: "Please chose an image", isPop: false)
            return
        }

        var setModel = MetaInfo()
        if let privateStr = self.commentField.text {
            setModel.privateArr = [privateStr]
        }
        let publicInfo = PublicModel(fn: name, image: avatar)
        setModel.publicInfo = publicInfo
        let subModel = SubcribeModel(topic: "new", get: [.data, .sub, .desc], data: nil, set: setModel)
        let vc = ChatVC.instance("", subModel: subModel)
        guard var arr = self.navigationController?.viewControllers else {return}
        arr.removeLast()
        arr.append(vc)
        self.navigationController?.setViewControllers(arr, animated: true)
    }
    
}

extension CreateGroupVC: WebSocketProtocol {
    
}

extension CreateGroupVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: UIImagePicker
extension CreateGroupVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let img = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }

        picker.dismiss(animated: true) {
            let squre = img.squreCrop()
            let resized = squre?.resizedImage(min: 128)
            self.avatar.image = resized
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupVC {
    private func viewInit() {
        self.avatar.setCorner(radius: 64)
        self.avatar.setBoardColor(hex: Configure.lightGray, width: 1)
        self.createBtn.setCorner(radius: 5)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickAvatar))
        self.avatar.addGestureRecognizer(tap)
    }

    @objc private func clickAvatar() {
        let alert = UIAlertController(title: nil, message: "Upload Photo", preferredStyle: .actionSheet)
        let album = UIAlertAction(title: "From album", style: .default) { (_) in
            self.showImagePicker(isCamera: false)
        }
        let camera = UIAlertAction(title: "From Camera", style: .default) { (_) in
            self.showImagePicker(isCamera: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(album)
        alert.addAction(camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func showImagePicker(isCamera: Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = (isCamera) ? .camera: .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
}
