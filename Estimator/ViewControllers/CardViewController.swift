//
//  CardViewController.swift
//  Estimator
//
//  Created by 전수열 on 7/29/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import UIKit

let timeout: NSTimeInterval = 3

public class CardViewController: UIViewController {

    public struct Metric {
        static let scrollerItemHeight = idiom(68, 100)
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

    private var transitionAnimator: BlurTransitionAnimator!

    private var panBeganLocationInCardView: CGFloat?


    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.transitionAnimator = BlurTransitionAnimator()
        self.transitioningDelegate = self.transitionAnimator
        self.modalPresentationStyle = .Custom

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
        self.cardView.frame.origin.y = self.view.frame.height - self.cardView.frame.height

        //
        // Scroller
        //
        let itemSize = CGSizeApplyAffineTransform(
            CardView.standardSize,
            CardView.transformThatFitsHeight(Metric.scrollerItemHeight)
        )

        var scrollerFrame = self.view.bounds
        scrollerFrame.size.height = itemSize.height
        scrollerFrame.origin.y = self.cardView.frame.origin.y - itemSize.height

        self.scroller = HScroller(frame: scrollerFrame)
        self.scroller.delegate = self
        self.scroller.itemSize = itemSize
        self.scroller.registerClass(CardCell.self)

        self.view.addSubview(self.cardView)
        self.view.addSubview(self.scroller)

        //
        // Gesture Recognizer
        //
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "gestureRecognizerHandler:")
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)

        let pressRecognizer = UILongPressGestureRecognizer(target: self, action: "gestureRecognizerHandler:")
        pressRecognizer.minimumPressDuration = 0.0001
        self.view.addGestureRecognizer(pressRecognizer)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.garbageCollector.invalidate()
        self.peer.broadcast(.None)
    }

    public override func viewDidDisappear(animated: Bool) {
        self.peer.stopBroadcasting()
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


// MARK: - PeerDelegate

extension CardViewController: PeerDelegate {

    public func peerDidBecomeActive(peer: Peer) {
        if let card = self.card {
            self.peer.broadcast(card)
            self.peer.listen()
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


// MARK: - HScrollerDelegate

extension CardViewController: HScrollerDelegate {

    public func numberOfItemsInScroller(scroller: HScroller) -> Int {
        return self.receivedPacketsByName.count
    }

    public func scroller(scroller: HScroller, needsConfigureCell rawCell: UICollectionViewCell, atIndex index: Int) {
        if let cell = rawCell as? CardCell {
            let packet = Array(self.receivedPacketsByName.values)[index]
            cell.name = packet.name
            cell.card = packet.card
        }
    }

}


// MARK: - GestureRecognizer

extension CardViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizerHandler(gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            if gestureRecognizer is UILongPressGestureRecognizer {
                guard let presentationLayer = self.cardView.layer.presentationLayer() as? CALayer else { break }
                let currentY = presentationLayer.frame.minY
                self.cardView.layer.removeAllAnimations()
                self.cardView.frame.origin.y = currentY
            } else if gestureRecognizer is UIPanGestureRecognizer {
                self.panBeganLocationInCardView = gestureRecognizer.locationInView(self.cardView).y
            }

        case .Changed:
            guard gestureRecognizer is UIPanGestureRecognizer else { break }
            guard let offset = self.panBeganLocationInCardView else { break }
            let point = gestureRecognizer.locationInView(self.view)
            let target = point.y - offset
            let delta = target - self.cardView.frame.origin.y
            let origin = self.view.frame.height - self.cardView.frame.height
            self.cardView.frame.origin.y = origin + delta / 1.5

        case .Ended:
            guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { fallthrough }
            let point = gestureRecognizer.locationInView(self.view)
            let origin = self.view.frame.height - self.cardView.frame.height
            let delta = point.y - origin
            let velocity = gestureRecognizer.velocityInView(self.view)
            print("delta: \(delta), velocity: \(velocity.y)")
            if delta >= 400 || velocity.y >= 1500 {
                self.dismissViewControllerAnimated(true, completion: nil)
            }

        case .Ended, .Cancelled:
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 500,
                initialSpringVelocity: 0,
                options: [.CurveEaseInOut, .AllowUserInteraction],
                animations: {
                    self.cardView.frame.origin.y = self.view.frame.height - self.cardView.frame.height
                },
                completion: { _ in
                    self.panBeganLocationInCardView = nil
                }
            )

        default: break
        }
    }

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWithGestureRecognizer
                                  otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}