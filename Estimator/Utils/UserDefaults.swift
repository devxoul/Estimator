//
//  UserDefaults.swift
//  Estimator
//
//  Created by 전수열 on 7/29/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import Foundation

public struct UserDefaultsKey {
    static let name = "Name"
}


public class UserDefaults {

    public class func sharedUserDefaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }

    public class func synchronize() {
        self.sharedUserDefaults().synchronize()
    }

    public class var name: String? {
        get {
            return self.sharedUserDefaults().stringForKey(UserDefaultsKey.name)
        }
        set {
            self.sharedUserDefaults().setValue(newValue, forKey: UserDefaultsKey.name)
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.nameDidChange, object: nil)
        }
    }

}