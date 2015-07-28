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

//    case Number0
//    case Number0_5
//    case Number1
//    case Number2
//    case Number3
//    case Number5
//    case Number8
//    case Number13
//    case Number20
//    case Number40
//    case Number100

    case QuestionMark
    case Coffee

    public var stringValue: String {
        return String(self.rawValue)
    }
}
