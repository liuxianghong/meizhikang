//
//  Array+Extenstion.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/6.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in enumerate() {
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}