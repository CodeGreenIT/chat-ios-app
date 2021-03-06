//
//  WebSocketManager.swift
//  G4HChat
//
//  Created by Codegreen on 19/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit
import Starscream
import MobileCoreServices

class WebSocketManager {

    enum MessageType {
        case Hi
        case Login
        case SubTopic
        case Leave
        case Get
        case Pub
        case Note
        case DelRoom
        case Set
        case Acc
        case Sub
    }

    static let shard = WebSocketManager()
    private let ws: WebSocket
    private var msgRecord: [String: MessageType]
    private(set) var saidHi: Bool = false
    private(set) var currentUser: UserModel?
    var delegate: WebSocketProtocol?

    init() {
        self.msgRecord = [:]
        self.ws = WebSocket(url: URL(string: Configure.socketURL)!)
        self.ws.advancedDelegate = self
    }

    func removeRecord(key: String) {
        self.msgRecord.removeValue(forKey: key)
    }

    func open() {
        self.ws.connect()
    }

    func send<T: Encodable>(model: T, type: MessageType,
                             id: String?) {
        let data = try! JSONEncoder().encode(model)
        if id != nil {
            self.msgRecord[id!] = type
        }
        self.ws.write(data: data)

    }

    func login(account: String, password: String) {
        let secret = "\(account):\(password)"
        let login = LoginModel(secret: secret.base64()!)
        self.send(model: login, type: .Login, id: login.login.id)
    }

    func subcribeMe() {
        let subModel = SubcribeModel(topic: "me", get: [.sub, .desc])
        self.send(model: subModel, type: .SubTopic,
                  id: subModel.sub.id)
    }

    func subcribeRoom(topic: String, limit: Int=24) {
        let data = SubDataModel(limit: limit)
        let sub = SubcribeModel(topic: topic, get: [.data, .sub, .desc], data: data)
        self.send(model: sub, type: .SubTopic, id: sub.sub.id)
    }

    func sendSub(model: SubcribeModel) {
        self.send(model: model, type: .Sub, id: model.sub.id)
    }

    func leaveTopic(_ topic: String) {
        let leaveModel = LeaveModel(topic: topic)
        self.send(model: leaveModel, type: .Leave,
                  id: leaveModel.leave.id)
    }

    func GetData(topic: String, what: [WhatEnum],
                 before: Int, limit: Int=24) {
        let getModel = GetModel(topic: topic, what: what,
                                before: before, limit: limit)
        self.send(model: getModel, type: .Get, id: getModel.get.id)
    }

    func pubData(topic: String, content: Any, name: String?=nil) {

        if let txt = content as? String {
            let pubModel = PubModel(topic: topic, content: txt)
            self.send(model: pubModel, type: .Pub,
                      id: pubModel.pub.id)
        } else if let img = content as? UIImage {
            guard let resized = img.resizeIfNeed(size: CGSize(width: 600, height: 600)) else {
                let err = "Send message error"
                self.delegate?.pubData(topic, error: err)
                return
            }
            guard let base64 = resized.base64Str() else {
                let err = "Send message error"
                self.delegate?.pubData(topic, error: err)
                return
            }
            let data = DataContentModel(base64Img: base64,
                                        size: resized.size,
                                        name: name)
            let pubModel = PubModel(topic: topic, content: data)
            self.send(model: pubModel, type: .Pub,
                      id: pubModel.pub.id)
        }
    }

    func sendNote(_ model: NoteModel) {
        self.send(model: model, type: .Note, id: nil)
    }

    func delRoom(topic: String, what: WhatEnum) {
        let delModel = DelModel(topic: topic, what: what)
        self.send(model: delModel, type: .DelRoom,
                  id: delModel.del.id)
    }

    func sendSetData(model: SetModel) {
        self.send(model: model, type: .Set, id: model.set.id)
    }

    func sendAccData(model: AccModel) {
        self.send(model: model, type: .Acc, id: model.acc.id)
    }
}

// MARK: echo
extension WebSocketManager: WebSocketAdvancedDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("WebSocket connection Open")
        self.sayHi()
    }

    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        print("WebSocket disconnect:\(error?.localizedDescription)")
        self.ws.connect()
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {

        let data = text.data(using: .utf8)!
        if text.hasPrefix("{\"ctrl\"") {
            let ctrlModel = try! JSONDecoder().decode(CtrlModel.self, from: data)
            self.handleCtrl(res: ctrlModel)
        } else if text.hasPrefix("{\"meta\"") {
            let metaModel = try! JSONDecoder().decode(MetaModel.self, from: data)
            self.handleMeta(meta: metaModel)
        } else if text.hasPrefix("{\"pres\"") {
            let presModel = try! JSONDecoder().decode(PresModel.self, from: data)
            self.handlePres(res: presModel)
        } else if text.hasPrefix("{\"data\"") {
            print("Get Subcribe Data")
            let dataModel = try! JSONDecoder().decode(DataModel.self, from: data)
            self.delegate?.subcribeData(dataModel.data)
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
        print("Websocket receive data")
    }

    func websocketHttpUpgrade(socket: WebSocket, request: String) {
        print("Websocket upgrade request info")
    }

    func websocketHttpUpgrade(socket: WebSocket, response: String) {
        print("Websocket upgrade response info")
    }
}

// MARK: Handle Func
extension WebSocketManager {

    private func handleCtrl(res: CtrlModel) {
        guard let type = self.msgRecord[res.ctrl.id] else {
            return
        }

        switch type {
        case .Hi:
            print("Get Hi Response")
            self.saidHi = true
            self.msgRecord.removeValue(forKey: res.ctrl.id)
        case .Login:
            print("Get Login Response")
            self.msgRecord.removeValue(forKey: res.ctrl.id)
            self.handleLogin(res: res)
        case .SubTopic, .Get, .Sub:
            print("Get Subcribe Room Ctrl")
            self.handleSubcribeTopic(res: res, meta: nil)
        case .Leave:
            print("Get Leave Response")
            self.handleLeave(res: res.ctrl)
        case .Pub:
            print("Get Pub Response")
            self.handlePub(res: res.ctrl)
        case .DelRoom:
            print("Get Del Response")
            self.handelDelRoom(res: res.ctrl)
        case .Set:
            print("Get Set Response")
            self.handleSet(res: res.ctrl)
        case .Acc:
            print("Get Acc Response")
            self.handleAcc(res: res.ctrl)
        default: return
        }
    }

    private func handleMeta(meta: MetaModel) {
        guard let type = self.msgRecord[meta.meta.id] else {
            return
        }
        switch type {
        case .SubTopic, .Sub:
            print("Get Subcribe Topic")
            self.handleSubcribeTopic(res: nil, meta: meta)
        default: return
        }
    }

    private func handlePres(res: PresModel) {
        if res.pres.topic == "me" {
            switch res.pres.what {
            case .on, .off:
                self.setChatRoomStatus(res: res)
            case .msg:
                self.setChatRoomUnRead(res: res)
            case .gone:
                self.removeChatRoom(res: res)
            default: return
            }

        }
    }

    private func handleLogin(res: CtrlModel) {
        guard res.ctrl.code == 200 else {
            self.delegate?.loginResult(user: nil,
                                       error: res.ctrl.text)
            return
        }
        let expire = res.ctrl.params!.expires!
        let token = res.ctrl.params!.token!
        let user = res.ctrl.params!.user!
        self.currentUser = UserModel(expires: expire.iSODate(),
                                     token: token, user: user)
        self.delegate?.loginResult(user: self.currentUser,
                                   error: nil)
    }

    private func handleSubcribeTopic(res: CtrlModel?,
                                     meta: MetaModel?) {
        
        if let res = res {
            let topic = res.ctrl.topic!
            guard res.ctrl.code == 200 else {
                let err = res.ctrl.text
                self.delegate?.subcribeTopic(topic, error: err)
                self.msgRecord.removeValue(forKey: res.ctrl.id)
                return
            }
            self.delegate?.subcribeTopic(topic, ctrl: res.ctrl)
        } else if let meta = meta {
            let topic = meta.meta.topic
            if meta.meta.desc != nil {
                self.handleMetaDesc(topic, desc: meta.meta.desc!)
            } else {
                let sub = meta.meta.sub ?? []
                self.delegate?.subcribeTopic(topic, metaInfo: sub)

                let arr = ["me", "fnd"]
                if arr.contains(meta.meta.topic) {
                    self.msgRecord.removeValue(forKey: meta.meta.id)
                }
            }
        }
    }

    private func handleLeave(res: CtrlContent) {
        self.msgRecord.removeValue(forKey: res.id)
        guard res.code == 200 else {
            self.leaveTopic(res.topic!)
            return
        }
    }

    private func handlePub(res: CtrlContent) {
        self.msgRecord.removeValue(forKey: res.id)
        guard res.code == 202 else {
            self.delegate?.pubData(res.topic!, error: res.text)
            return
        }
    }

    private func handleMetaDesc(_ topic: String, desc: MetaInfo) {
        if topic == "me" {
            self.setUserInfo(desc: desc)
        } else {
            self.delegate?.subcribeTopic(topic, desc: desc)
        }
    }

    private func handelDelRoom(res: CtrlContent) {
        self.msgRecord.removeValue(forKey: res.id)
        let isSuccess = (res.code == 200)
        self.delegate?.delRoomRes(topic: res.topic!,
                                  isSuccess: isSuccess)
    }

    private func handleSet(res: CtrlContent) {
        self.msgRecord.removeValue(forKey: res.id)
        let isSuccess = (res.code == 200)
        self.delegate?.setRes(topic: res.topic!,
                              isSuccess: isSuccess)
    }

    private func handleAcc(res: CtrlContent) {
        self.msgRecord.removeValue(forKey: res.id)
        let isSuccess = (res.code == 200)
        self.delegate?.accRes(isSuccess: isSuccess)
    }
}

// MARK: Func
extension WebSocketManager {

    private func sayHi() {
        let hiModel = HiModel()
        self.msgRecord[hiModel.hi.id] = .Hi
        self.send(model: hiModel, type: .Hi, id: hiModel.hi.id)
    }

    private func setUserInfo(desc: MetaInfo) {
        self.currentUser?.name = (desc.publicInfo?.fn)!
        let imgDataStr = desc.publicInfo?.photo!.imgData
        self.currentUser?.photo = imgDataStr?.base64Image()!
    }

    func setUserName(name: String) {
        self.currentUser?.name = name
    }

    func setAccount(account: String) {
        self.currentUser?.account = account
    }

    private func setChatRoomStatus(res: PresModel) {
        let vc = UIApplication.getHomeVC()
        vc?.setRoomStatus(src: res.pres.src, status: res.pres.what.rawValue)
    }

    private func setChatRoomUnRead(res: PresModel) {
        let vc = UIApplication.getHomeVC()
        vc?.setCharRoomUnRead(res: res)
    }

    private func removeChatRoom(res: PresModel) {
        let vc = UIApplication.getHomeVC()
        vc?.removeChatRoom(res: res)
    }

    func addChatRoomIfNeed(topic: String, desc: MetaInfo) {
        let vc = UIApplication.getHomeVC()
        var _desc = desc
        _desc.topic = topic
        vc?.addToListIfNeed(topic: topic, desc: _desc)
    }
}
