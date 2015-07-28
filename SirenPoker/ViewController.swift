//
//  ViewController.swift
//  SirenPoker
//
//  Created by 전수열 on 7/24/15.
//  Copyright (c) 2015 Suyeol Jeon. All rights reserved.
//

import CoreBluetooth
import UIKit

public class ViewController: UIViewController {

    public var textView: UITextView!
    public var sendButton: UIButton!

    public var peer: Peer!
    public var receivedPacketsByName: [String: Packet]!


    public override func viewDidLoad() {
        super.viewDidLoad()

        self.peer = Peer()
        self.peer.delegate = self
        self.peer.channel = "00"
        self.peer.name = "전수열"

        self.receivedPacketsByName = [:]

        self.textView = UITextView(frame: self.view.bounds)
        self.textView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.textView.contentInset.top = 20
        self.textView.editable = false
        self.textView.alwaysBounceVertical = true
        self.view.addSubview(self.textView)

        self.sendButton = UIButton(type: .System)
        self.sendButton.frame.origin.x = 100
        self.sendButton.frame.origin.y = 100
        self.sendButton.enabled = false
        self.sendButton.setTitle("Send", forState: .Normal)
        self.sendButton.sizeToFit()
        self.sendButton.addTarget(self, action: "send", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.sendButton)
    }

    public func updateConsole() {
        var text = ""
        for (name, packet) in receivedPacketsByName {
            text += "\(name): \(packet.card!.rawValue)"
        }
        self.textView.text = text
    }

    public func send() {
        self.peer.startBroadcasting(.Coffee)
    }

}


extension ViewController: PeerDelegate {

    public func peerDidBecomeActive(peer: Peer) {
        self.sendButton.enabled = true
    }

    public func peerDidBecomeInactive(peer: Peer) {
        self.sendButton.enabled = false
    }

    public func peer(peer: Peer, didReceivePacket packet: Packet) {
        if let name = packet.name {
            self.receivedPacketsByName[name] = packet
            self.updateConsole()
        }
    }

}
