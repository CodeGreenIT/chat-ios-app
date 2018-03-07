//
//  SubByIDVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 05/03/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class SubByIDVC: UIViewController {

    @IBOutlet var idTextField: UITextField!
    @IBOutlet var subBtn: UIButton!

    private let socket = WebSocketManager.shard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func thePageShow() {
        self.socket.delegate = self
    }

    @IBAction func clickSubBtn(_ sender: Any) {
    }
    
}

extension SubByIDVC: WebSocketProtocol {

}

extension SubByIDVC {
    private func viewInit() {
        self.subBtn.setCorner(radius: 5)
    }
}
