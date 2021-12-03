//
//  Media
//
//  Created by Ravikant Kumar on 02/12/21.
//

import Foundation
import CoreData
import UIKit


@objc(Picture)
public class Picture: NSManagedObject {
    convenience init(dictionary: photoInfo , context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: type(of: self).entityName(), in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = dictionary.title
            self.explanation = dictionary.description
            self.dateString = dictionary.date
            self.urlString = dictionary.url.absoluteString
        } else {
            fatalError("Unable to find Entity Name")
        }
    }
}
