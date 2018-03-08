//
//  ProfileVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 27/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UITextField!
    @IBOutlet var password: UITextField!

    private let socket = WebSocketManager.shard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.socket.delegate = self
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileVC: WebSocketProtocol {
    private func setUserName() {
        self.view.makeToastActivity(.center)
        let publicModel = PublicModel(fn: self.name.text!,
                                      image: self.avatar.image!)
//        let desc = DescModel(privateInfo: nil, defacs: nil, publicInfo: publicModel)
        var desc = MetaInfo()
        desc.publicInfo = publicModel
        let set = SetModel(desc: desc, topic: "me")
        self.socket.sendSetData(model: set)
    }

    func setRes(topic: String, isSuccess: Bool) {
        guard topic == "me" else {return}
        self.view.hideToastActivity()

        if isSuccess {
            self.socket.setUserName(name: self.name.text!)
        } else {
            self.name.text = self.socket.currentUser?.name
            self.view.makeToast("failed")
        }
    }

    private func setPassword(new: String, check: String) {
        guard new != "" && check != "" else {
            self.noticeAlert(title: "Error", message: "Please enter password", isPop: false)
            return
        }
        guard new == check else {
            self.noticeAlert(title: "Error", message: "Different input", isPop: false)
            return
        }

        self.view.makeToastActivity(.center)
        let secret = "\(self.socket.currentUser!.account!):\(new)"
        let acc = AccModel(secret: secret.base64()!)
        self.socket.sendAccData(model: acc)
    }

    func accRes(isSuccess: Bool) {
        self.view.hideToastActivity()
        let word = (isSuccess) ? "success": "failed"
        if let tab = self.navigationController?.viewControllers.first as? UITabBarController {
            let height = tab.tabBar.frame.size.height
            let size = self.view.bounds.size

            let point = CGPoint(x: size.width/2, y: size.height-height-30)
            self.view.makeToast(word, point: point, title: nil, image: nil, completion: nil)
        }
    }
}

extension ProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.name {
            self.checkSetName()
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.password {
            self.checkSetPassword()
            return false
        }
        else {
            return true
        }
    }
}

extension ProfileVC {
    private func viewInit() {
        self.avatar.setCorner(radius: 32)
        self.setData()
    }

    private func setData() {
        guard let user = socket.currentUser else {return}
        if let photo = user.photo {
            self.avatar.image = photo
        }
        self.name.text = user.name
        self.password.text = "**********"
    }

    private func checkSetName() {
        guard self.name.text!.count > 0 else {
            self.noticeAlert(title: "Error", message: "Please enter name", isPop: false)
            return
        }
        guard self.name.text != self.socket.currentUser?.name else {
            return
        }

        let alert = UIAlertController(title: nil, message: "Do you want to change name?", preferredStyle: .alert)
        let sure = UIAlertAction(title: "Sure", style: .default) { (_) in
            self.setUserName()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.name.text = self.socket.currentUser?.name
        }
        alert.addAction(sure)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func checkSetPassword() {
        let alert = UIAlertController(title: "Change Password", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter again"
            textField.isSecureTextEntry = true
        }
        let save = UIAlertAction(title: "Save", style: .default) { (_) in
            var new = ""
            var check = ""
            for textField in alert.textFields! {
                if (textField.placeholder?.contains("New"))! {
                    new = textField.text!
                } else {
                    check = textField.text!
                }
            }
            self.setPassword(new: new, check: check)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(save)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
