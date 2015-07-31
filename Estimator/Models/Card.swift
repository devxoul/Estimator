//
//  Card.swift
//  Estimator
//
//  Created by 전수열 on 7/28/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import Foundation

public enum Card: Int {
    case Zero = 0
    case Half = 127
    case One = 1
    case Two = 2
    case Three = 3
    case Five = 5
    case Eight = 8
    case Thirteen = 13
    case Twenty = 20
    case Fourty = 40
    case Hundred = 100
    case QuestionMark = 0xFD
    case Coffee = 0xFE
    case None = 0xFF

    public var hexValue: String {
        let hex = String(self.rawValue, radix: 16, uppercase: true)
        if self.rawValue < 0xA {
            return "0" + hex
        }
        return hex
    }

    public var text: String {
        switch self {
            case .Half: return "0.5"
            case .QuestionMark: return "?"
            case .Coffee: return "☕️"
            case .None: return "None"
            default: return String(self.rawValue)
        }
    }

    public static let allValues: [Card] = [
        .Zero,
        .Half,
        .One,
        .Two,
        .Three,
        .Five,
        .Eight,
        .Thirteen,
        .Twenty,
        .Fourty,
        .Hundred,
        .QuestionMark,
        .Coffee
    ]
}


extension Card: CustomStringConvertible {

    public var description: String {
        return "<Card: \(self.text)>"
    }

}
