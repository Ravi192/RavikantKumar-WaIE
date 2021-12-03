//
//  Picture+CoreDataProperties.swift
//  
//
//  Created by Ravikant Kumar on 02/12/21.
//
//

import Foundation
import CoreData


extension Picture {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Picture> {
        return NSFetchRequest<Picture>(entityName: self.entityName())
    }

    @NSManaged public var title: String?
    @NSManaged public var explanation: String?
    @NSManaged public var dateString: String?
    @NSManaged public var urlString: String?
}
