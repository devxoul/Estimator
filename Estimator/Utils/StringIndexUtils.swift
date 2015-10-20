//
//  StringIndexUtils.swift
//  Estimator
//
//  Created by 전수열 on 7/31/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import Foundation

extension String {

    public subscript (range: Range<Int>) -> String? {
        guard range.startIndex < self.characters.count else {
            return nil
        }
        let startIndex = self.startIndex.advancedBy(range.startIndex)
        let endIndex = startIndex.advancedBy(range.endIndex - range.startIndex)
        return self.substringWithRange(startIndex..<endIndex)
    }

}

infix operator ..< {}
public func ..< (lhs: String.Index, rhs: Int) -> Range<String.Index> {
    return lhs..<(lhs + rhs)
}

infix operator ... {}
public func ... (lhs: String.Index, rhs: Int) -> Range<String.Index> {
    return lhs...(lhs + rhs)
}

infix operator + {}
public func + (lhs: String.Index, rhs: Int) -> String.Index {
    return lhs.advancedBy(rhs)
}

infix operator - {}
public func - (lhs: String.Index, rhs: Int) -> String.Index {
    return lhs.advancedBy(-rhs)
}
