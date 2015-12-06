//
//  EasyOptionalUnwrapping.swift
//  Where'sBaby
//
//  Created by shadowPriest on 15/11/4.
//  Copyright © 2015年 coolLH. All rights reserved.
//

import Foundation

infix operator ?={ associativity right precedence 90}
func ?=<T>(inout left: T, right :T?){
    if let value = right{
        left = value
    }
}

func ?=<T>(inout left: T?, right :T?){
    if let value = right{
        left = value
    }
}