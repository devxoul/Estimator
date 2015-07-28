//
//  DeckViewController.swift
//  SirenPoker
//
//  Created by 전수열 on 7/24/15.
//  Copyright (c) 2015 Suyeol Jeon. All rights reserved.
//

import CoreBluetooth
import UIKit

public class DeckViewController: UIViewController {

    public struct Metric {
        static let scrollerContentInset: CGFloat = 40
    }

    public var scroller: HScroller!


    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Planning Poker"
        self.automaticallyAdjustsScrollViewInsets = false

        var itemSize = self.view.bounds.size
        itemSize.width -= Metric.scrollerContentInset * 2
        itemSize.height *= itemSize.width / self.view.bounds.size.width

        var scrollerFrame = self.view.bounds
        scrollerFrame.size.height = itemSize.height

        self.scroller = HScroller(frame: scrollerFrame)
        self.scroller.center.y = (self.view.bounds.size.height + 64) / 2
        self.scroller.delegate = self
        self.scroller.itemSize = itemSize
        self.scroller.contentInset = Metric.scrollerContentInset
        self.scroller.pagingEnabled = true
        self.scroller.canScrollMultiplePages = true
        self.scroller.registerClass(CardCell.self)
        self.view.addSubview(self.scroller)
    }
}


extension DeckViewController: HScrollerDelegate {

    public func numberOfItemsInScroller(scroller: HScroller) -> Int {
        return Card.allValues.count
    }

    public func scroller(scroller: HScroller, needsConfigureCell rawCell: UICollectionViewCell, atIndex index: Int) {
        if let cell = rawCell as? CardCell {
            cell.card = Card.allValues[index]
        }
    }

    public func scroller(scroller: HScroller, didSelectItemAtIndex index: Int) {
        let cardViewController = CardViewController()
        cardViewController.card = Card.allValues[index]
        self.presentViewController(cardViewController, animated: true, completion: nil)
    }

}
