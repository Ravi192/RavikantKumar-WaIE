//
//  NSManagedObject+Entity.swift
//  Virtual Tourist
//
//  Created by Ravikant Kumar on 02/12/21.
//

import Foundation
import CoreData

extension NSManagedObject {
    class func entityName() -> String {
        return String(describing: self)
    }
}
