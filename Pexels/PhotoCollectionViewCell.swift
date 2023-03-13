//
//  PhotoCollectionViewCell.swift
//  Pexels
//
//  Created by Zhangali Pernebayev on 13.03.2023.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "PhotoCollectionViewCell"

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
