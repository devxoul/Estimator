//
//  Packet.swift
//  SirenPoker
//
//  Created by 전수열 on 7/28/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import Foundation

private let latestVersion = "01"
private let delimiter = ":"

public struct Packet: Equatable {

    public var version: String? // 2byte
    public var channel: String? // 2byte
    public var name: String?
    public var card: Card?
    public var receivedAt: NSDate?


    public init(version: String, channel: String, name: String, card: Card?) {
        self.version = version
        self.channel = channel
        self.name = name
        self.card = card
    }

    public init(channel: String, name: String, card: Card?) {
        self.version = latestVersion
        self.channel = channel
        self.name = name
        self.card = card
    }

    public init?(encoded: String) {
        let components = encoded.componentsSeparatedByString(delimiter)
        if components.count == 4 {
            let version = components[0]
            let channel = components[1]
            let name = components[2]
            var card: Card? = nil
            if let rawValue = Int(components[3]) {
                card = Card(rawValue: rawValue) ?? Card.QuestionMark
            }
            self.init(version: version, channel: channel, name: name, card: card)
        } else {
            return nil
        }
    }

    public func encode() -> String {
        let components = [self.version, self.channel, self.name, self.card?.stringValue].map { $0 ?? "" }
        return delimiter.join(components)
    }

}


extension Packet: CustomStringConvertible {

    public var description: String {
        let components = [self.version, self.channel, self.name, self.card?.description].map { $0 ?? "" }
        return delimiter.join(components)
    }

}


public func == (lhs: Packet, rhs: Packet) -> Bool {
    return lhs.version == rhs.version && lhs.channel == rhs.channel && lhs.name == rhs.name && lhs.card == rhs.card
}
