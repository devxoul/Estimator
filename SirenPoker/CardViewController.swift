//
//  CardViewController.swift
//  SirenPoker
//
//  Created by 전수열 on 7/29/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import UIKit

public class CardViewController: UIViewController {

    public var peer: Peer!
    public var receivedPacketsByName: [String: Packet]!

    public var card: Card? {
        didSet {
            self.cardDidSet()
        }
    }

    internal var cardView: CardCell!
    internal var scroller: HScroller!

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.backgroundColor = UIColor.whiteColor()

        self.peer = Peer()
        self.peer.delegate = self
        self.peer.channel = "00"
        self.peer.name = "전수열"

        self.receivedPacketsByName = [:]

        //
        // Card View
        //
        var cardViewFrame = self.view.bounds
        cardViewFrame.size.height -= 64
        self.cardView = CardCell(frame: cardViewFrame)
        self.view.addSubview(self.cardView)

        //
        // Scroller
        //
        var itemSize = self.view.bounds.size
        itemSize.width = 48
        itemSize.height = 64

        var scrollerFrame = self.view.bounds
        scrollerFrame.size.height = itemSize.height
        scrollerFrame.origin.y = self.view.bounds.size.height - scrollerFrame.size.height

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
        self.peer.stopBroadcasting()
    }

    public func backgroundDidTap() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    internal func cardDidSet() {
        self.cardView.card = self.card
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

    public func peer(peer: Peer, didReceivePacket packet: Packet) {
        if let name = packet.name {
            self.receivedPacketsByName[name] = packet
            self.scroller.reloadData()
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
