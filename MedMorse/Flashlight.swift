//
//  Flashlight.swift
//  MedMorse
//
//  Created by Zack Bartel on 3/6/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import AVFoundation

struct Flashlight {
    
    static let device = AVCaptureDevice.default(for: AVMediaType.video)
    
    static func hasTorch() -> Bool {
        guard (device != nil) else { return false }
        guard device!.hasTorch else {  return false }
        return true
    }
    
    static func setTorch(on: Bool) {
        do {
            try device?.lockForConfiguration()
            device?.torchMode = on ? .on : .off
            if on { try device?.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel) }
            device?.unlockForConfiguration()
        } catch {
            print("Torch can't be used")
        }
    }
}
