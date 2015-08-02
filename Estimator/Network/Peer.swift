//
//  Peer.swift
//  Estimator
//
//  Created by 전수열 on 7/28/15.
//  Copyright © 2015 Suyeol Jeon. All rights reserved.
//

import CoreBluetooth
import Foundation

public let serviceUUIDString = "FB3367FD-09F8-4E08-9F6B-07E309FD2576"

public class Peer: NSObject {

    private var peripheral: CBPeripheralManager!
    private var central: CBCentralManager!

    public weak var delegate: PeerDelegate?

    public var channel: String?
    public var name: String?

    private var isPeripheralActive = false {
        didSet { self.delegateActivationIfNeeded(oldValue && self.isCentralActive) }
    }
    private var isCentralActive = false {
        didSet { self.delegateActivationIfNeeded(oldValue && self.isPeripheralActive) }
    }
    public var active: Bool {
        return self.isPeripheralActive && self.isCentralActive
    }

    public var currentPacket: Packet?


    public override init() {
        super.init()
        self.peripheral = CBPeripheralManager(delegate: self, queue: nil)
        self.central = CBCentralManager(delegate: self, queue: nil)
    }

    public convenience init(channel: String, name: String) {
        self.init()
        self.channel = channel
        self.name = name
    }


    // MARK: Broadcasting

    public func startBroadcasting(card: Card) {
        if let channel = self.channel, name = self.name {
            let packet = Packet(channel: channel, name: name, card: card)
            self.startBroadcasting(packet)
        } else {
            if self.channel == nil {
                NSLog("[WARNING] Channel is nil.")
            }
            if self.name == nil {
                NSLog("[WARNING] Name is nil.")
            }
            NSLog("[WARNING] Skip broadcasting.")
        }
    }

    public func startBroadcasting(packet: Packet) {
        if !self.active {
            NSLog("[WARNING] Peer is not active. Skip broadcasting.")
            return
        }
        let encoded = packet.encode()
        NSLog("Start broadcasting: \(encoded)")
        self.peripheral.stopAdvertising()
        self.peripheral.startAdvertising([
            CBAdvertisementDataLocalNameKey: encoded,
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: serviceUUIDString)],
        ])
    }

    public func stopBroadcasting() {
        self.peripheral.stopAdvertising()
    }


    // MARK: Listening

    public func listen() -> Bool {
        guard self.isCentralActive else {
            NSLog("[WARNING] Peer is not active. Skip listening.")
            return false
        }
        let serviceUUID = CBUUID(string: serviceUUIDString)
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        self.central.scanForPeripheralsWithServices([serviceUUID], options: options)
        return true
    }

    public func stopListening() {
        self.central.stopScan()
    }


    // MARK: Active

    private func delegateActivationIfNeeded(wasActive: Bool) {
        if !wasActive && self.active {
            self.delegate?.peerDidBecomeActive(self)
        } else if wasActive && !self.active {
            self.delegate?.peerDidBecomeInactive(self)
        }
    }

}


extension Peer: CBPeripheralManagerDelegate {

    public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .PoweredOn:
            let serviceUUID = CBUUID(string: serviceUUIDString)
            let service = CBMutableService(type: serviceUUID, primary: true)
            self.peripheral.addService(service)

        default:
            break
        }
    }

    public func peripheralManager(peripheral: CBPeripheralManager,
                                  didAddService service: CBService,
                                  error: NSError?) {
        self.isPeripheralActive = true
    }

    public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
//        self.log("[Peripheral] Send")
    }

}


extension Peer: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            self.isCentralActive = true

        default:
            break
        }
    }

    public func centralManager(central: CBCentralManager,
                               didDiscoverPeripheral peripheral: CBPeripheral,
                               advertisementData: [String : AnyObject],
                               RSSI: NSNumber) {
        if let data = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
           let packet = Packet(encoded: data) {
            self.delegate?.peer(self, didReceivePacket: packet)
        }
    }

}


public protocol PeerDelegate: NSObjectProtocol {

    func peerDidBecomeActive(peer: Peer)
    func peerDidBecomeInactive(peer: Peer)
    func peer(peer: Peer, didReceivePacket packet: Packet)

}
