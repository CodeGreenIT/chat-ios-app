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
    var desc: DescModel?
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
        self.desc = try json.decodeIfPresent(DescModel.self, forKey: .desc)
        self.sub = try json.decodeIfPresent([MetaInfo].self, forKey: .sub)
    }
}

struct DescModel: Codable {
    var privateInfo: PrivateModel?
    var defacs: DefacsModel?
    var publicInfo: PublicModel?

    private enum CodingKeys: String, CodingKey {
        case defacs
        case privateInfo = "private"
        case publicInfo = "public"
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        if let publiceModel = try? json.decode(PublicModel.self, forKey: .publicInfo) {
            self.publicInfo = publiceModel
        }
        self.defacs = try? json.decode(DefacsModel.self, forKey: .defacs)
        if let str = try? json.decode(String.self, forKey: .privateInfo) {
            self.privateInfo = PrivateModel(comment: nil, privateStr: str)
        } else if let strArr = try? json.decode([String].self, forKey: .privateInfo) {
            let str = strArr.joined(separator: ", ")
            self.privateInfo = PrivateModel(comment: nil, privateStr: str)
        } else {
            self.privateInfo = try? json.decode(PrivateModel.self, forKey: .privateInfo)
        }
    }

    public init(privateInfo: PrivateModel?, defacs: DefacsModel?, publicInfo: PublicModel) {
        self.privateInfo = privateInfo
        self.defacs = defacs
        self.publicInfo = publicInfo
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
    var acs: ACSModel
    var privateArr: [String]?
    var publicInfo: PublicModel?
    var read: Int?
    var recv: Int?
    var seq: Int?
    var topic: String?
    var updated: Date?
    var deleted: Date?
    var online: Bool?
    var user: String?

    private enum CodingKeys: String, CodingKey {
        case acs
        case privateArr = "private"
        case publicInfo = "public"
        case read, recv, seq, topic, updated, online, user, deleted
    }

    public init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        self.acs = try! json.decode(ACSModel.self, forKey: .acs)
        if let arr = try? json.decode([String].self, forKey: .privateArr) {
            self.privateArr = arr
        } else if let str = try? json.decode(String.self, forKey: .privateArr) {
            self.privateArr = [str]
        }
        self.publicInfo = try? json.decode(PublicModel.self, forKey: .publicInfo)
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

    public init(acs: ACSModel) {
        self.acs = acs
    }
}

