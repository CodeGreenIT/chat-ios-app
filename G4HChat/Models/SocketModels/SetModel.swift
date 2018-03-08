//
//  SetModel.swift
//  G4HChat
//
//  Created by 陳建佑 on 28/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct SetModel: Codable {
    var set: SetContent
    public init(desc: MetaInfo, topic: String) {
        self.set = SetContent(desc: desc, topic: topic)
    }
}

struct SetContent: Codable {
    var desc: MetaInfo
    var id: String
    var topic: String

    public init(desc: MetaInfo, topic: String) {
        self.id = UUID().uuidString
        self.desc = desc
        self.topic = topic
    }
}
