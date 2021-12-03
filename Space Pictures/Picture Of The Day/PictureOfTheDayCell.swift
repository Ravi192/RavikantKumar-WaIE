//
//  PictureOfTheDayTableViewCell.swift
//
//  Created by Ravikant Kumar on 03/12/21.
//

import UIKit

class PictureOfTheDayCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "cell"
    
    @IBOutlet weak var pictureOfTheDay: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var gradientView: UIView!

    @IBOutlet weak var descriptionView: UITextView!
    
}

