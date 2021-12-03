//
//  DictionaryExtension.swift
//
//  Created by Ravikant Kumar on 03/12/21.
//

import Foundation

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
