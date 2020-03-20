//
//  ToneGenerator.swift
//  MedMorse
//
//  Created by Zack Bartel on 3/1/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//
// Thanks: https://github.com/rnapier/ToneGen/blob/master/ToneGen/ToneGenerator.swift

import Foundation

import Foundation
import AVFoundation

class ToneGenerator: AVAudioPlayerNode {

    var buffer: SineWaveAudioBuffer?

    var frequency: Double

    var amplitude: Double

    fileprivate let format: AVAudioFormat

    init(frequency: Double, amplitude: Double, format: AVAudioFormat) {
        self.frequency = frequency
        self.amplitude = amplitude
        self.format = format
        super.init()
    }
    
    private static let engine: AVAudioEngine = {
        do {
               try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
               try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
           } catch let error {
               print(error)
           }
        return AVAudioEngine()
    }()
    
    override convenience init() {
        self.init(engine: ToneGenerator.engine)
    }
    
    convenience init(engine: AVAudioEngine) {
        self.init(frequency: 500, amplitude: __exp10(-12.0/10), format: engine.mainMixerNode.outputFormat(forBus: 0))
        engine.attach(self)
        engine.connect(self, to: engine.mainMixerNode, format:nil)
        try! engine.start()
    }

    convenience init(format: AVAudioFormat) {
        self.init(frequency: 0, amplitude: 0, format: format)
    }

    override func play() {
        super.play()
        updateTone()
    }
    
    override func stop() {
        guard self.engine != nil else { return }
        let buf = RampDownAudioBuffer(frequency: frequency, amplitude: buffer!.amplitude, format: self.format)
        scheduleBuffer(buf, at: nil, options: [.interruptsAtLoop], completionHandler: nil)
    }

    func updateTone() {
        guard self.engine != nil else { return }
        buffer = SineWaveAudioBuffer(frequency: frequency, amplitude: amplitude, format: self.format)
        scheduleBuffer(buffer!, at: nil, options: [.loops, .interruptsAtLoop], completionHandler: nil)
    }
}

class SineWaveAudioBuffer: AVAudioPCMBuffer {
    
    var amplitude: Double = 0

    init(frequency: Double, amplitude: Double, format: AVAudioFormat) {
        if frequency < 0 {
            fatalError("Frequency must not be negative")
        }
        if amplitude < 0 || amplitude > 1.0 {
            fatalError("Amplitude must be between 0 and 1")
        }
        
        self.amplitude = amplitude

        let sr = Double(format.sampleRate)
        let samples: AVAudioFrameCount = {
            guard frequency != 0 else { return 1 }
            return max(AVAudioFrameCount(sr / frequency), 1)
        }()

        super.init(pcmFormat: format, frameCapacity: samples)!

        self.frameLength = self.frameCapacity

        let numChan = Int(format.channelCount)
        let w = 2 * .pi * frequency

        for t in 0..<Int(self.frameLength) {
            let value = Float(amplitude * sin(w * Double(t) / sr))
            for c in 0..<numChan {
                self.floatChannelData?[c][t] = value
            }
        }
    }
}

class RampDownAudioBuffer: AVAudioPCMBuffer {
    
    init(frequency: Double, amplitude: Double, format: AVAudioFormat) {
        if frequency < 0 {
            fatalError("Frequency must not be negative")
        }
        if amplitude < 0 || amplitude > 1.0 {
            fatalError("Amplitude must be between 0 and 1")
        }
        
        let sr = Double(format.sampleRate)
        let samples: AVAudioFrameCount = {
            guard frequency != 0 else { return 1 }
            return max(AVAudioFrameCount(sr / frequency), 1)
        }()
        
        super.init(pcmFormat: format, frameCapacity: samples)!
        
        self.frameLength = self.frameCapacity
        
        let numChan = Int(format.channelCount)
        let w = 2 * .pi * frequency
        
        var a = amplitude
        let down = (amplitude / Double(self.frameLength))
        
        for t in 0..<Int(self.frameLength) {
            a = a - down
            if t == Int(self.frameLength) {
                a = .zero
            }
            let value = Float(a * sin(w * Double(t) / sr))
            for c in 0..<numChan {
                self.floatChannelData?[c][t] = value
            }
        }
    }
}
