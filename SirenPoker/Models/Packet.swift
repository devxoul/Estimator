//
//  Packet.swift
//  SirenPoker
//
//  Created by 전수열 on 7/28/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import Foundation

private let latestVersion = "01"

public struct Packet: Equatable {

    public var version: String? // 2 bytes
    public var channel: String? // 2 bytes
    public var card: Card?      // 2 bytes
    public var name: String?
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
        guard encoded.characters.count > 7 else { return nil }
        guard let version = encoded[0..<2] else { return nil }
        guard let channel = encoded[2..<4] else { return nil }
        guard let card = encoded[4..<6], cardRawValue = Int(card, radix: 16) else { return nil }

        self.version = version
        self.channel = channel
        self.card = Card(rawValue: cardRawValue)
        self.name = encoded.substringFromIndex(advance(encoded.startIndex, 6))
    }

    public func encode() -> String {
        let components = [self.version, self.channel, self.card?.hexValue, self.name].map { $0 ?? "" }
        return "".join(components)
    }

}


extension Packet: CustomStringConvertible {

    public var description: String {
        let components = [self.version, self.channel, self.card?.description, self.name].map { $0 ?? "" }
        return ", ".join(components)
    }

}


public func == (lhs: Packet, rhs: Packet) -> Bool {
    return lhs.version == rhs.version && lhs.channel == rhs.channel && lhs.card == rhs.card && lhs.name == rhs.name
}
