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
    }
    
}

extension CreateGroupVC: WebSocketProtocol {
    
}

extension CreateGroupVC {
    private func viewInit() {
        self.avatar.setCorner(radius: 64)
        self.avatar.setBoardColor(hex: Configure.lightGray, width: 1)
        self.createBtn.setCorner(radius: 5)
    }
}
