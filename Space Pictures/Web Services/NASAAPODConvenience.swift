//
//  NASAAPODConvenience.swift
//
//  Created by Ravikant Kumar on 03/12/21.
//

import Foundation
import CoreData
import UIKit

extension NASAAPODClient {
    var sharedStack: CoreDataStackManager {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.dataStack
    }
    
    var sharedContext: NSManagedObjectContext {
        return sharedStack.context
    }
    
    func picturesFromResults1(results: photoInfo) {
                let picture = Picture(dictionary: results, context: self.sharedContext)
                self.sharedContext.insert(picture)
                self.sharedStack.save()
    }

    
  
    
    // NB: Concept Tags are currently turned off in NASA's service
    func getPhotos(startDate: Date, endDate: Date, conceptTags: Bool = false, completionHandlerForPictures: @escaping (_ success: Bool, _ error: Error?) -> Void){
        let startDateString = format(date: startDate)
        let endDateString = format(date: endDate)
        let conceptTagsValueString = conceptTags ? "True" : "False"
        let parameters = [URLKeys.StartDate: startDateString as AnyObject,
                          URLKeys.EndDate: endDateString as AnyObject,
                          URLKeys.ConceptTags: conceptTagsValueString as AnyObject]
        let _ = taskForGETMethod1(parseJSON: true) { (result, error, data) in
            if (error != nil) {
                completionHandlerForPictures(false, error)
            } else {
                let jsonDecoder = JSONDecoder()
                if let photoInfo = try? jsonDecoder.decode(photoInfo.self, from: data) {
                    self.picturesFromResults1(results: photoInfo)
                    completionHandlerForPictures(true, nil)
                } else {
                    completionHandlerForPictures(false, error)
                }
            }
        }
    }
    
    // Format dates to the String value required for the APOD API
    private func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: date)
    }
}
