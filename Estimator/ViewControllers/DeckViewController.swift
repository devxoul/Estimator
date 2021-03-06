//
//  DeckViewController.swift
//  Estimator
//
//  Created by 전수열 on 7/24/15.
//  Copyright (c) 2015 Suyeol Jeon. All rights reserved.
//

import CoreBluetooth
import UIKit

public class DeckViewController: UIViewController {

    public struct Metric {
        static let scrollerContentInset = idiom(40, 80)
        static let scrollerItemSpacing = idiom(10, 20)
    }

    public var scroller: HScroller!


    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Estimator"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: nil, // will be set in `viewWillAppear:`
            style: .Plain,
            target: self,
            action: "nameButtonDidTap"
        )

        self.automaticallyAdjustsScrollViewInsets = false

        let itemWidth = self.view.bounds.width - Metric.scrollerContentInset * 2
        let itemSize = CGSizeApplyAffineTransform(CardView.standardSize, CardView.transformThatFitsWidth(itemWidth))

        var scrollerFrame = self.view.bounds
        scrollerFrame.size.height = itemSize.height

        self.scroller = HScroller(frame: scrollerFrame)
        self.scroller.center.y = (self.view.bounds.size.height + 64) / 2
        self.scroller.delegate = self
        self.scroller.itemSize = itemSize
        self.scroller.itemSpacing = Metric.scrollerItemSpacing
        self.scroller.contentInset = Metric.scrollerContentInset
        self.scroller.pagingEnabled = true
        self.scroller.canScrollMultiplePages = true
        self.scroller.registerClass(CardCell.self)
        self.view.addSubview(self.scroller)

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "nameDidChange",
            name: NotificationName.nameDidChange,
            object: nil
        )
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.nameDidChange()
    }

    public func nameButtonDidTap() {
        let alertController = UIAlertController(title: "Edit Name", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "New name"
            textField.text = UserDefaults.name
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
            let textField = alertController.textFields![0]
            textField.resignFirstResponder()
            UserDefaults.name = textField.text
            UserDefaults.synchronize()
        })
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    public func nameDidChange() {
        self.navigationItem.leftBarButtonItem?.title = UserDefaults.name ?? "No name"
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
