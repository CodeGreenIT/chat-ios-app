//
//  AccModel.swift
//  G4HChat
//
//  Created by 陳建佑 on 01/03/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
struct AccModel: Codable {
    var acc: AccContent
    public init(secret: String, scheme: SchemeEnum = .basic) {
        self.acc = AccContent(secret: secret, scheme: scheme)
    }
}

struct AccContent: Codable {
    var id: String
    var scheme: String
    var secret: String
    public init(secret: String, scheme: SchemeEnum = .basic) {
        self.id = UUID().uuidString
        self.scheme = scheme.rawValue
        self.secret = secret
    }
}
