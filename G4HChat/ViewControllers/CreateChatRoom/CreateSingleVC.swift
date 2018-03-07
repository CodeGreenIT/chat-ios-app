//
//  CreateSingleVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 05/03/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class CreateSingleVC: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private let socket = WebSocketManager.shard
    var people = [MetaInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.socket.delegate = self
        self.getRoomInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func thePageShow() {
        self.socket.delegate = self
    }
}

extension CreateSingleVC: WebSocketProtocol {
    private func getRoomInfo() {
        let model = SubcribeModel(topic: "fnd", get: [.sub, .desc])
        self.socket.sendSub(model: model)
    }

    func subcribeTopic(_ topic: String, error: String) {
        self.noticeAlert(title: "Error", message: error)
    }

    func subcribeTopic(_ topic: String, metaInfo: [MetaInfo]) {
        self.people = metaInfo
        self.tableView.reloadData()
    }
}

extension CreateSingleVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoom") as! ChatInfoCell
        let data = self.people[indexPath.row]
        if let photo = data.publicInfo?.photo {
            cell.avatar.image = photo.imgData.base64Image()
        }

        cell.titleLabel.text = data.publicInfo?.fn
        cell.messageLabel.text = data.privateArr?.joined(separator: ", ")
        cell.unReadNum = 0
        cell.showStatus = false

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = self.people[indexPath.row]
        let vc = ChatVC.instance(data.user!)

        guard var arr = self.navigationController?.viewControllers else {return}
        arr.removeLast()
        arr.append(vc)
        self.navigationController?.setViewControllers(arr, animated: true)
    }
}

extension CreateSingleVC {
    private func viewInit() {
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        let nib = ChatInfoCell.nib()
        self.tableView.register(nib,
                                forCellReuseIdentifier: "ChatRoom")
    }
}
