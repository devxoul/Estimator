//
//  CardViewController.swift
//  SirenPoker
//
//  Created by 전수열 on 7/29/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import UIKit

let timeout: NSTimeInterval = 3

public class CardViewController: UIViewController {

    public struct Metric {
        static let scrollerItemHeight = idiom(88, 100)
    }

    public var peer: Peer!
    public var receivedPacketsByName: [String: Packet]!

    public var card: Card? {
        didSet {
            self.cardDidSet()
        }
    }

    internal var cardView: CardView!
    internal var scroller: HScroller!
    internal var garbageCollector: NSTimer!

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.backgroundColor = UIColor.whiteColor()

        self.peer = Peer()
        self.peer.delegate = self
        self.peer.channel = "00"
        self.peer.name = UserDefaults.name

        self.receivedPacketsByName = [:]

        self.garbageCollector = NSTimer(
            timeInterval: 1,
            target: self,
            selector: "collectGarbages",
            userInfo: nil,
            repeats: true
        )
        NSRunLoop.currentRunLoop().addTimer(self.garbageCollector, forMode: NSRunLoopCommonModes)

        //
        // Card View
        //
        self.cardView = CardView()
        self.cardView.transform = CardView.transformThatFits(self.view.bounds.size)
        self.cardView.frame.origin.y = 0
        self.view.addSubview(self.cardView)

        //
        // Scroller
        //
        let itemSize = CGSizeApplyAffineTransform(
            CardView.standardSize,
            CardView.transformThatFitsHeight(Metric.scrollerItemHeight)
        )

        var scrollerFrame = self.view.bounds
        scrollerFrame.size.height = itemSize.height
        scrollerFrame.origin.y = self.view.bounds.size.height - itemSize.height

        self.scroller = HScroller(frame: scrollerFrame)
        self.scroller.delegate = self
        self.scroller.itemSize = itemSize
        self.scroller.registerClass(CardCell.self)
        self.view.addSubview(self.scroller)

        // FIXME: Temp
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "backgroundDidTap")
        self.view.addGestureRecognizer(tapRecognizer)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.garbageCollector.invalidate()
        self.peer.startBroadcasting(.None)
    }

    public override func viewDidDisappear(animated: Bool) {
        self.peer.stopBroadcasting()
    }

    public func backgroundDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    internal func cardDidSet() {
        self.cardView.card = self.card
    }

    public func collectGarbages() {
        for (name, packet) in self.receivedPacketsByName {
            if abs(packet.receivedAt?.timeIntervalSinceNow ?? timeout) >= timeout {
                self.removeName(name)
            }
        }
        self.scroller.reloadData()
    }

    public func removeName(name: String) {
        if self.receivedPacketsByName.removeValueForKey(name) != nil {
            NSLog("Remove '\(name)'")
        }
    }

}


extension CardViewController: PeerDelegate {

    public func peerDidBecomeActive(peer: Peer) {
        if let card = self.card {
            self.peer.startBroadcasting(card)
        }
    }

    public func peerDidBecomeInactive(peer: Peer) {

    }

    public func peer(peer: Peer, var didReceivePacket packet: Packet) {
        if let name = packet.name, card = packet.card {
            if card != .None {
                packet.receivedAt = NSDate()
                self.receivedPacketsByName[name] = packet
                self.scroller.reloadData()
            } else {
                self.removeName(name)
            }
        }
    }
    
}


extension CardViewController: HScrollerDelegate {

    public func numberOfItemsInScroller(scroller: HScroller) -> Int {
        return self.receivedPacketsByName.count
    }

    public func scroller(scroller: HScroller, needsConfigureCell rawCell: UICollectionViewCell, atIndex index: Int) {
        if let cell = rawCell as? CardCell {
            let packet = self.receivedPacketsByName.values.array[index]
            cell.name = packet.name
            cell.card = packet.card
        }
    }
    
}
