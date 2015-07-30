//
//  CardView.swift
//  SirenPoker
//
//  Created by 전수열 on 7/30/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import UIKit

public final class CardView: UIView {

    internal struct Metric {
        static let borderWidth = 1.f
        static let cornerRadius = 10.f
    }

    internal struct Font {
        static let nameLabel = UIFont.systemFontOfSize(idiom(80, 160))
        static let cardLabel = UIFont.systemFontOfSize(idiom(120, 240))
    }

    internal struct Color {
        static let shadow = 0x0~50%
        static let background = 0xEDEDED~
        static let border = 0xCCCCCC~
    }


    public static let standardSize = CGSize(
        width: UIScreen.mainScreen().bounds.width,
        height: ceil(UIScreen.mainScreen().bounds.width * idiom(3 / 2, 4 / 3))
    )

    private var backgroundView: UIImageView!
    private var nameLabel: UILabel!
    private var cardLabel: UILabel!

    public var name: String? {
        get { return self.nameLabel.text }
        set { self.nameLabel.text = newValue }
    }
    public var card: Card? {
        didSet {
            self.cardDidSet()
        }
    }


    // MARK: Init

    public override init(frame: CGRect) {
        super.init(frame: CGRect(origin: frame.origin, size: self.dynamicType.standardSize))

        self.backgroundView = UIImageView(frame: self.bounds)
        self.backgroundView.image = UIImage.resizable()
                                           .color(Color.background)
                                           .border(color: Color.border)
                                           .border(width: Metric.borderWidth)
                                           .corner(radius: Metric.cornerRadius)
                                           .image()

        self.nameLabel = UILabel()
        self.nameLabel.font = Font.nameLabel
        self.nameLabel.textAlignment = .Center

        self.cardLabel = UILabel(frame: self.bounds)
        self.cardLabel.font = Font.cardLabel
        self.cardLabel.textAlignment = .Center
        self.cardLabel.adjustsFontSizeToFitWidth = true

        self.addSubview(self.backgroundView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.cardLabel)
    }

    public convenience init() {
        self.init(frame: CGRect(origin: CGPoint.zeroPoint, size: self.dynamicType.standardSize))
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: DidSet

    private func cardDidSet() {
        self.cardLabel.text = self.card?.text
    }


    // MARK: Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        self.nameLabel.sizeToFit()
        self.nameLabel.bounds.size.width = self.bounds.width
        self.nameLabel.center.x = self.bounds.width / 2

        self.cardLabel.sizeToFit()
        self.cardLabel.bounds.size.width = self.bounds.width
        self.cardLabel.center.x = self.bounds.width / 2
        self.cardLabel.center.y = (self.bounds.height + self.nameLabel.bounds.height) / 2
    }


    // MARK: Transform

    public class func transformThatFits(size: CGSize) -> CGAffineTransform {
        let ratio = min(size.width / self.standardSize.width, size.height / self.standardSize.height)
        return CGAffineTransformMakeScale(ratio, ratio)
    }

    public class func transformThatFitsWidth(width: CGFloat) -> CGAffineTransform {
        return self.transformThatFits(CGSize(width: width, height: CGFloat.max))
    }

    public class func transformThatFitsHeight(height: CGFloat) -> CGAffineTransform {
        return self.transformThatFits(CGSize(width: CGFloat.max, height: height))
    }

}
