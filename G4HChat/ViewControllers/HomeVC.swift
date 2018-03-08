//
//  HomeVC.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    @IBOutlet var tableView: UITableView!

    private let socket = WebSocketManager.shard
    private var roomList = [MetaInfo]()
    private var isFirst = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigateionBar()
        self.socket.delegate = self
        if self.isFirst {
            self.socket.subcribeMe()
            self.isFirst = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeVC: WebSocketProtocol {
    func subcribeTopic(_ topic: String, error: String) {
        guard topic == "me" else {return}
        self.view.hideToastActivity()
        self.noticeAlert(title: "Error", message: error)
    }

    func subcribeTopic(_ topic: String, metaInfo: [MetaInfo]) {
        guard topic == "me" else {return}
        self.view.hideToastActivity()
        let filter = metaInfo.filter({$0.deleted == nil})
        self.roomList = filter
        self.tableView.reloadData()
    }

    func delRoomRes(topic: String, isSuccess: Bool) {
        self.view.hideToastActivity()
        guard isSuccess else {
            self.noticeAlert(title: "Error", message: "Delete chatroom failed", isPop: false)
            return
        }

        if let idx = self.roomList.index(where: {$0.topic == topic}) {
            self.roomList.remove(at: idx)
            let path = IndexPath(row: idx, section: 0)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [path], with: .left)
            self.tableView.endUpdates()
        }

    }
}

// MARK: UITableView
extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.roomList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoom") as! ChatInfoCell
        let data = self.roomList[indexPath.row]
        if let photo = data.publicInfo?.photo {
            cell.avatar.image = photo.imgData.base64Image()
        } 

        cell.titleLabel.text = data.publicInfo?.fn
        cell.messageLabel.text = data.privateArr?[0]
        let seq = data.seq ?? 0
        let read = data.read ?? 0
        cell.unReadNum = seq - read
        cell.isOnline = data.online ?? false

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = self.roomList[indexPath.row]
        let vc = ChatVC.instance(data.topic!)
        self.navigationController?.show(vc, sender: self)
        self.readRoom(path: indexPath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let data = self.roomList[indexPath.row]
            let topic = data.topic!
            self.socket.delRoom(topic: topic, what: .topic)
            self.view.makeToastActivity(.center)
        default: return
        }
    }
}

// MARK: Funcs
extension HomeVC {
    private func viewInit() {
        self.view.makeToastActivity(.center)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        let nib = ChatInfoCell.nib()
        self.tableView.register(nib,
                                forCellReuseIdentifier: "ChatRoom")
    }

    private func setNavigateionBar() {
        self.navigationController?.navigationBar.topItem?.title = "CHAT"
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addChatRoom))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = item
    }

    private func readRoom(path: IndexPath) {
        var data = self.roomList[path.row]
        data.read = data.seq
        self.roomList[path.row] = data
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [path], with: .fade)
        self.tableView.endUpdates()
    }

    func setRoomStatus(src: String, status: String) {
        let idx = self.roomList.index(where: {$0.topic == src})
        guard idx != nil else {return}
        self.roomList[idx!].online = (status == "on") ? true: false

        let path = IndexPath(row: idx!, section: 0)
        self.tableView.reloadRows(at: [path], with: .fade)
    }

    func addToListIfNeed(topic: String, desc: MetaInfo) {
        guard !self.roomList.contains(where: {$0.topic == topic}) else {return}

        self.roomList.append(desc)
        self.tableView.beginUpdates()
        let path = IndexPath(row: self.roomList.count-1, section: 0)
        self.tableView.insertRows(at: [path], with: .fade)
        self.tableView.endUpdates()
    }

    func setCharRoomUnRead(res: PresModel) {
        guard let idx = self.roomList.index(where: {$0.topic == res.pres.src}) else {return}
        var data = self.roomList[idx]
        data.seq = res.pres.seq
        self.roomList[idx] = data
        self.tableView.beginUpdates()
        let path = IndexPath(row: idx, section: 0)
        self.tableView.reloadRows(at: [path], with: .fade)
        self.tableView.endUpdates()
    }

    @objc private func addChatRoom() {
        let vc = CreateRoomVC.instance()
        self.navigationController?.show(vc, sender: self)
    }
}
