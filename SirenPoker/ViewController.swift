//
//  ViewController.swift
//  SirenPoker
//
//  Created by 전수열 on 7/24/15.
//  Copyright (c) 2015 Suyeol Jeon. All rights reserved.
//

import TheAmazingAudioEngine
import UIKit

class ViewController: UIViewController {

    var point = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.point.backgroundColor = UIColor.redColor()
        self.point.frame.size.width = 10
        self.point.frame.size.height = 10
        self.point.center.x = self.view.bounds.size.width / 2
        self.point.center.y = self.view.bounds.size.height / 2
        self.point.layer.cornerRadius = 5
        self.point.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.point.layer.shouldRasterize = true
        self.view.addSubview(self.point)

        println("Start receiving audio")
        let audioDescription = AEAudioController.nonInterleaved16BitStereoAudioDescription()
        let audioController = AEAudioController(audioDescription: audioDescription, inputEnabled: true)
        audioController.start(nil)
        let receiver = AEBlockAudioReceiver { source, time, frames, audio in
            let buffers = UnsafeMutableAudioBufferListPointer(audio)
            for buffer in buffers {
                let dataPointer = UnsafePointer<Int16>(buffer.mData)
                let dataLength = Int(buffer.mDataByteSize) / sizeof(Int16)
                let data = UnsafeBufferPointer<Int16>(start:dataPointer, count: dataLength)
                for i in 0..<data.count {
                    let datum = data[i]
                    let delta = CGFloat(datum) / 10
                    println(delta)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.point.center.y = self.view.bounds.size.height / 2 + delta
                    }
                }
            }
        }
        audioController.addInputReceiver(receiver)
    }

}
