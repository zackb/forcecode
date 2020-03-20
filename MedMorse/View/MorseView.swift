//
//  MorseView.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/26/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import UIKit

protocol MorseViewDelegate {
    func onCode(code: Character)
    func onCharacter(character: String)
    func onWordBreak()
    func onTapBegan()
    func onTapEnded()
    func onTapCanceled()
}

class MorseView: UIView {
    
    var delegate: MorseViewDelegate!

    public var durationDash = 0.300
    public var characterPause = 0.650
    public var wordPause = 1.600
    public var forceTouchEnabled = true
    public var forceTouchSensitivity: CGFloat = 0.3
    
    private var timeTapDown: Date?
    private var timeTapUp: Date?
    private var forceTouching = false

    private var wordTimer: Timer?
    private var characterTimer: Timer?
    private var buffer = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = Prefs.morseViewColor
    }
    
    private func tapBegan() {
        timeTapDown = Date()
        timeTapUp = nil
        stopWordTimer()
        stopCharacterTimer()
        delegate?.onTapBegan()
    }
    
    private func tapEnded() {
        if timeTapDown == nil {
            if buffer != "" {
                delegate.onCharacter(character: MorseCoder.decode(buffer))
            }
            print("MerW!?")
            tapCancelled()
            return
        }
        timeTapUp = Date()
        let timeTapSecs = timeTapUp!.timeIntervalSince1970 - timeTapDown!.timeIntervalSince1970
        let code: Character = timeTapSecs < durationDash ? "•" : "-"
        timeTapDown = nil
        delegate.onCode(code: code)
        buffer.append(code)
        startCharacterTimer()
        startWordTimer()
        delegate?.onTapEnded()
    }
    
    private func tapCancelled() {
        print("Cancelled")
        stopCharacterTimer()
        stopWordTimer()
        timeTapDown = nil
        timeTapUp = nil
        buffer = ""
        delegate?.onTapCanceled()
    }

    // MARK: Word Timer
    @objc func wordTimerEnded() {
        delegate.onWordBreak()
    }
    
    private func stopWordTimer() {
        wordTimer?.invalidate()
        wordTimer = nil
    }
    
    private func startWordTimer() {
        stopWordTimer()
        wordTimer = Timer.scheduledTimer(timeInterval: wordPause, target: self, selector: #selector(wordTimerEnded), userInfo: nil, repeats: false)
    }
    
    // MARK: Character Timer
    @objc func characterTimerEnded() {
        let trans = buffer.replacingOccurrences(of: "•", with: ".")
        delegate.onCharacter(character: MorseCoder.decode(trans))
        buffer = ""
    }
    
    private func stopCharacterTimer() {
        characterTimer?.invalidate()
        characterTimer = nil
    }
    
    private func startCharacterTimer() {
        stopCharacterTimer()
        characterTimer = Timer.scheduledTimer(timeInterval: characterPause, target: self, selector: #selector(characterTimerEnded), userInfo: nil, repeats: false)
    }
    
    // MARK: Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        forceTouching = false
        initial = true
        tapBegan()
        super.touchesBegan(touches, with: event)
    }
    
    private var initial = false
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !forceTouchEnabled {
            return
        }
        
        if let touch = touches.first {
            let force = touch.force / touch.maximumPossibleForce
            if !forceTouching && force > forceTouchSensitivity {
                if initial && Date().timeIntervalSince1970 - timeTapDown!.timeIntervalSince1970 < characterPause {
                    // TODO: clean
                } else if !initial || buffer == "" {
                    print("Force Began")
                    forceTouching = true
                    initial = false
                    tapBegan()
                }
            } else if forceTouching && force < forceTouchSensitivity {
                print("Force Ended")
                forceTouching = false
                tapEnded()
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        forceTouching = false
        initial = false
        tapEnded()
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        tapCancelled()
    }
}
