//
//  LoginModel.swift
//  G4HChat
//
//  Created by Codegreen on 20/01/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
enum SchemeEnum: String {
    case basic = "basic"
}

struct LoginModel: Codable {
    var login: LoginContent

    init(secret: String, scheme: SchemeEnum = .basic) {
        self.login = LoginContent(secret: secret, scheme: scheme)
    }
}

struct LoginContent: Codable {
    var id: String
    var scheme: String
    var secret: String

    init(secret: String, scheme: SchemeEnum = .basic) {
        self.id = UUID().uuidString
        self.secret = secret
        self.scheme = scheme.rawValue
    }
}
