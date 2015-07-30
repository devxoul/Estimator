//
//  Integer.swift
//  StyleShare
//
//  Created by 전수열 on 2015. 6. 4..
//  Copyright (c) 2015년 StyleShare Inc. All rights reserved.
//

import CoreGraphics
import UIKit

extension IntegerLiteralType {
    var f: CGFloat { return CGFloat(self) }
}

extension FloatLiteralType {
    var f: CGFloat { return CGFloat(self) }
}


func idiom(phoneValue: CGFloat, _ padValue: CGFloat) -> CGFloat {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        return phoneValue
    }
    return padValue
}
