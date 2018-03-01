//
//  DelModel.swift
//  G4HChat
//
//  Created by 陳建佑 on 26/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct DelModel: Codable {
    var del: DelContent
    public init(topic: String, what: WhatEnum) {
        self.del = DelContent(topic: topic, what: what)
    }
}

struct DelContent: Codable {
    var id: String
    var topic: String
    var what: String

    public init(topic: String, what: WhatEnum) {
        self.id = UUID().uuidString
        self.topic = topic
        self.what = what.rawValue
    }
}
