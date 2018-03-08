//
//  PresModel.swift
//  G4HChat
//
//  Created by Codegreen on 28/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct PresModel: Codable {
    var pres: PresContent
}

struct PresContent: Codable {
    var topic: String
    var src: String
    var what: WhatEnum
    var seq: Int?

    enum CodingKeys: String, CodingKey {
        case topic, src, what, seq
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(topic, forKey: .topic)
        try container.encode(src, forKey: .src)
        try container.encode(what.rawValue, forKey: .what)
        if let _seq = self.seq {
            try container.encode(_seq, forKey: .seq)
        }
    }

    init(from decoder: Decoder) throws {
        let json = try decoder.container(keyedBy: CodingKeys.self)
        self.topic = try! json.decode(String.self, forKey: .topic)
        self.src = try! json.decode(String.self, forKey: .src)
        let what = try! json.decode(String.self, forKey: .what)
        self.what = WhatEnum(rawValue: what)!
        self.seq = try? json.decode(Int.self, forKey: .seq)
    }
}
