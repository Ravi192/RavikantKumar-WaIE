//
//  photoInfo.swift
//
//  Created by Ravikant Kumar on 02/12/21.
//

import Foundation
public struct photoInfo: Codable {
     var date: String
     var title: String
     var description: String
     var url: URL
     var copyright: String?
     enum CodingKeys: String, CodingKey {
         case date
         case title
         case description  = "explanation"
         case url
         case copyright
     }
 }
