//
//  SearchTextCollectionViewCell.swift
//  Pexels
//
//  Created by Zhangali Pernebayev on 13.03.2023.
//

import UIKit

class SearchTextCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "SearchTextCollectionViewCell"
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 10
    }

    func set(title: String) {
        titleLabel.text = title
    }
}
