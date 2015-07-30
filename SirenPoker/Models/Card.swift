//
//  Card.swift
//  SirenPoker
//
//  Created by 전수열 on 7/28/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import Foundation

public enum Card: Int {
    case Zero
    case Half
    case One
    case Two
    case Three
    case Five
    case Eight
    case Thirteen
    case Twenty
    case Fourty
    case Hundred
    case QuestionMark
    case Coffee

    public var stringValue: String {
        return String(self.rawValue)
    }

    public var text: String {
        switch self {
        case .Zero: return "0"
        case .Half: return "0.5"
        case .One: return "1"
        case .Two: return "2"
        case .Three: return "3"
        case .Five: return "5"
        case .Eight: return "8"
        case .Thirteen: return "13"
        case .Twenty: return "20"
        case .Fourty: return "40"
        case .Hundred: return "100"
        case .QuestionMark: return "?"
        case .Coffee: return "Coffee"
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
