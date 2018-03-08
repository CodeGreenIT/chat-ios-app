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

    init(topic: String, get: [WhatEnum], data: SubDataModel?=nil, set: MetaInfo?=nil) {
        self.id = UUID().uuidString
        self.topic = topic
        self.get = SubGetModel(what: get, data: data)
        self.set = set
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
