//
//  CardCell.swift
//  Estimator
//
//  Created by 전수열 on 7/29/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import UIKit

public class CardCell: UICollectionViewCell {

    private var cardView: CardView!

    public var name: String? {
        get {
            return self.cardView.name
        }
        set {
            self.cardView.name = newValue
        }
    }
    public var card: Card? {
        didSet {
            self.cardView.card = self.card
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.cardView = CardView()
        self.contentView.addSubview(self.cardView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.cardView.transform = CardView.transformThatFits(self.bounds.size)
        self.cardView.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    }

}
