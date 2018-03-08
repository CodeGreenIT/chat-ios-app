//
//  MetaModel.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit
struct MetaModel: Codable {
    var meta: MetaContent
}

struct MetaContent: Codable {
    var id: String
    var topic: String
    var ts: Date
    var desc: MetaInfo?
    var sub: [MetaInfo]?

    private enum CodingKeys: String, CodingKey {
        case id, topic, ts, desc, sub
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try! json.decode(String.self, forKey: .id)
        self.topic = try! json.decode(String.self, forKey: .topic)
        let tsStr = try! json.decode(String.self, forKey: .ts)
        self.ts = tsStr.iSODate()
        self.desc = try json.decodeIfPresent(MetaInfo.self, forKey: .desc)
        self.sub = try json.decodeIfPresent([MetaInfo].self, forKey: .sub)
    }
}

struct DefacsModel: Codable {
    var auth: String
    var anon: String
}

struct PublicModel: Codable {
    var fn: String
    var photo: PhotoModel?
    public init(fn: String, image: UIImage?) {
        self.fn = fn
        if let img = image {
            let base64 = img.base64Str()!
            self.photo = PhotoModel(imgData: base64, type: "jpg")
        }
    }
}

struct PrivateModel: Codable {
    var comment: String?
    var privateStr: String?

    private enum CodingKeys: String, CodingKey {
        case comment, privateStr
    }
}

struct PhotoModel: Codable {
    var imgData: String
    var type: String

    private enum CodingKeys: String, CodingKey {
        case imgData = "data"
        case type
    }
}

struct MetaInfo: Codable {
    var acs: ACSModel?
    var privateArr: [String]?
    var publicInfo: PublicModel?
    var defacs: DefacsModel?
    var read: Int?
    var recv: Int?
    var seq: Int?
    var topic: String?
    var updated: Date?
    var deleted: Date?
    var online: Bool?
    var user: String?

    private enum CodingKeys: String, CodingKey {
        case acs, defacs
        case privateArr = "private"
        case publicInfo = "public"
        case read, recv, seq, topic, updated, online, user, deleted
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        self.acs = try? json.decode(ACSModel.self, forKey: .acs)
        if let arr = try? json.decode([String].self, forKey: .privateArr) {
            self.privateArr = arr
        } else if let str = try? json.decode(String.self, forKey: .privateArr) {
            self.privateArr = [str]
        }
        self.publicInfo = try? json.decode(PublicModel.self, forKey: .publicInfo)
        self.defacs = try? json.decode(DefacsModel.self, forKey: .defacs)
        self.read = try? json.decode(Int.self, forKey: .read)
        self.recv = try? json.decode(Int.self, forKey: .recv)
        self.seq = try? json.decode(Int.self, forKey: .seq)
        self.topic = try? json.decode(String.self, forKey: .topic)
        if let tsStr = try? json.decode(String.self, forKey: .updated) {
            self.updated = tsStr.iSODate()
        }

        if let delDateStr = try? json.decode(String.self, forKey: .deleted) {
            self.deleted = delDateStr.iSODate()
        }
        self.online = try? json.decode(Bool.self, forKey: .online)
        self.user = try? json.decode(String.self, forKey: .user)
    }

    public init() {
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.user, forKey: .user)
        try container.encodeIfPresent(self.online, forKey: .online)
        try container.encodeIfPresent(self.deleted?.iSOStr(), forKey: .deleted)
        try container.encodeIfPresent(self.updated?.iSOStr(), forKey: .updated)
        try container.encodeIfPresent(self.topic, forKey: .topic)
        try container.encodeIfPresent(self.seq, forKey: .seq)
        try container.encodeIfPresent(self.recv, forKey: .recv)
        try container.encodeIfPresent(self.read, forKey: .read)
        try container.encodeIfPresent(self.defacs, forKey: .defacs)
        try container.encodeIfPresent(self.publicInfo, forKey: .publicInfo)
        try container.encodeIfPresent(self.privateArr?.joined(separator: ", "), forKey: .privateArr)
    }
}

