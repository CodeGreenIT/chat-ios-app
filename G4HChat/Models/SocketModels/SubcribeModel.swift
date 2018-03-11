//
//  SubcribeModel.swift
//  G4HChat
//
//  Created by Codegreen on 27/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct SubcribeModel: Codable {
    var sub: SubcribeContent

    init(topic: String, get: [WhatEnum], data: SubDataModel?=nil, set: MetaInfo?=nil) {
        self.sub = SubcribeContent(topic: topic, get: get,
                                   data: data, set: set)
    }
}

struct SubcribeContent: Codable {
    var id: String
    var topic: String
    var get: SubGetModel
    var set: MetaInfo?

    private enum CodingKeys: String, CodingKey {
        case id, topic, get, set
    }

    init(topic: String, get: [WhatEnum], data: SubDataModel?=nil, set: MetaInfo?=nil) {
        self.id = UUID().uuidString
        self.topic = topic
        self.get = SubGetModel(what: get, data: data)
        self.set = set
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.topic, forKey: .topic)
        try container.encode(self.get, forKey: .get)
        if let desc = self.set {
            let dic = ["desc": desc]
            try container.encode(dic, forKey: .set)
        }
    }
}

struct SubGetModel: Codable {
    var what: String
    var data: SubDataModel?
    public init(what: [WhatEnum], data: SubDataModel?) {
        let whatRaw = what.flatMap { (what) -> String? in
            return what.rawValue
        }
        self.what = whatRaw.joined(separator: " ")
        self.data = data
    }
}

struct SubDataModel: Codable {
    var limit: Int
}
