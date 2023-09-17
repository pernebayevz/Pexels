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
    
    var deleteButtonWasTapped: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 10
    }

    func set(title: String) {
        self.titleLabel.text = title
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        
        bounce(button: sender) {
            self.deleteButtonWasTapped?()
        }
    }
    
    func bounce(button: UIButton, completion: @escaping (()->())) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    button.transform = CGAffineTransform.identity
                } completion: { completed in
                    if completed {
                        completion()
                    }
                }
            }
        )
    }
}


