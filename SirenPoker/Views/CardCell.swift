//
//  CardCell.swift
//  SirenPoker
//
//  Created by 전수열 on 7/29/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import UIKit

public class CardCell: UICollectionViewCell {

    public struct Font {
        static let nameLabel = UIFont.systemFontOfSize(14)
        static let cardLabel = UIFont.systemFontOfSize(80)
    }

    internal var nameLabel: UILabel!
    internal var cardLabel: UILabel!

    public var name: String? {
        didSet {
            self.nameDidSet()
        }
    }
    public var card: Card? {
        didSet {
            self.cardDidSet()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        self.layer.cornerRadius = 5

        self.nameLabel = UILabel()
        self.nameLabel.font = Font.nameLabel
        self.nameLabel.textAlignment = .Center
        self.nameLabel.adjustsFontSizeToFitWidth = true

        self.cardLabel = UILabel(frame: self.bounds)
        self.cardLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.cardLabel.font = Font.cardLabel
        self.cardLabel.textAlignment = .Center
        self.cardLabel.adjustsFontSizeToFitWidth = true

        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.cardLabel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func nameDidSet() {
        self.nameLabel.text = self.name
    }

    internal func cardDidSet() {
        self.cardLabel.text = self.card?.text
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        self.nameLabel.sizeToFit()
        self.nameLabel.bounds.size.width = self.contentView.bounds.size.width
    }

}
