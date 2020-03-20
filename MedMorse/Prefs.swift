//
//  Prefs.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/27/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import Foundation
import UIKit

struct Prefs {
    
    static let morseViewColor = UIColor.black
    static let textViewColor  = UIColor.black
    static let codeViewColor  = UIColor.clear
    static let codeFontSize: CGFloat = 100.0
    
    
    static let KeyWordsPerMinute            = "pref_wordsPerMinute"
    static let KeyFarnsworthEnabled         = "pref_farnsworthEnabled"
    
    static let KeyDashDuration              = "pref_dashDuration"
    static let KeyWordPause                 = "pref_wordPause"
    static let KeyCharacterPause            = "pref_characterPause"
    
    static let KeyForceTouchSensitivity     = "pref_forceTouchSensitivity"
    static let KeyForceTouchEnabled         = "pref_forceTouchEnabled"
    
    static let KeyFeedbackVibrateEnabled    = "pref_feedbackVibrateEnabled"
    static let KeyFeedbackSoundEnabled      = "pref_feedbackSoundEnabled"
    static let KeyFeedbackSoundFrequency    = "pref_feedbackSoundFrequency"
    static let KeyFeedbackFlashEnabled      = "pref_feedbackFlashEnabled"
    static let KeyFeedbackTorchEnabled      = "pref_feedbackTorchEnabled"
    
    static let KeyGestureShakeEnabled       = "pref_gestureShakeEnabled"
    static let KeyGestureSwipeLeftEnabled   = "pref_gestureSwipeLeftEnabled"
    static let KeyGestureSwipeRightEnabled  = "pref_gestureSwipeRightEnabled"
    
    static func wpm() -> Double {
        return doubleValue(KeyWordsPerMinute, defaul: 12.0)
    }
    
    static func setWpm(_ value: Double) {
        UserDefaults.standard.set(value, forKey: KeyWordsPerMinute)
    }
    
    static func farnsworthEnabled() -> Bool {
        return boolValue(KeyFarnsworthEnabled, defaul: true)
    }
    
    static func setFarnsworthEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyFarnsworthEnabled)
    }
    
    static func dashDuration() -> Double {
        return doubleValue(KeyDashDuration, defaul: 0.250)
    }
    
    static func setDashDuration(_ value: Double) {
        UserDefaults.standard.set(value, forKey: KeyDashDuration)
    }
    
    static func wordPause() -> Double {
        return doubleValue(KeyWordPause, defaul: 1.7)
    }
    
    static func setWordPause(_ value: Double) {
        UserDefaults.standard.set(value, forKey: KeyWordPause)
    }
    
    static func characterPause() -> Double {
        return doubleValue(KeyCharacterPause, defaul: 0.650)
    }
    
    static func setCharacterPause(_ value: Double) {
        UserDefaults.standard.set(value, forKey: KeyCharacterPause)
    }
    
    static func forceTouchSensitivity() -> Double {
        return doubleValue(KeyForceTouchSensitivity, defaul: 0.3)
    }
    
    static func setForceTouchSensitivity(_ value: Double) {
        UserDefaults.standard.set(value, forKey: KeyForceTouchSensitivity)
    }
    
    static func forceTouchEnabled() -> Bool {
        return boolValue(KeyForceTouchEnabled, defaul: true)
    }
    
    static func setForceTouchEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyForceTouchEnabled)
    }
    
    static func feedbackVibrateEnabled() -> Bool {
        return boolValue(KeyFeedbackVibrateEnabled, defaul: true)
    }
    
    static func setFeedbackVibrateEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyFeedbackVibrateEnabled)
    }
    
    static func feedbackSoundEnabled() -> Bool {
        return boolValue(KeyFeedbackSoundEnabled, defaul: false)
    }
    
    static func setFeedbackSoundEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyFeedbackSoundEnabled)
    }
    
    static func feedbackSoundFrequency() -> Double {
        return doubleValue(KeyFeedbackSoundFrequency, defaul: 500.0)
    }
    
    static func setFeedbackSoundFrequency(_ value: Double) {
        UserDefaults.standard.set(value, forKey: KeyFeedbackSoundFrequency)
    }
    
    static func feedbackFlashEnabled() -> Bool {
        return boolValue(KeyFeedbackFlashEnabled, defaul: false)
    }
    
    static func setFeedbackFlashEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyFeedbackFlashEnabled)
    }
    
    static func feedbackTorchEnabled() -> Bool {
        return boolValue(KeyFeedbackTorchEnabled, defaul: false)
    }
    
    static func setFeedbackTorchEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyFeedbackTorchEnabled)
    }
    
    static func gestureShakeEnabled() -> Bool {
        return boolValue(KeyGestureShakeEnabled, defaul: true)
    }
    
    static func setGestureShakeEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyGestureShakeEnabled)
    }
    
    static func gestureSwipeLeftEnabled() -> Bool {
        return boolValue(KeyGestureSwipeLeftEnabled, defaul: true)
    }
    
    static func setGestureSwipeLeftEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyGestureSwipeLeftEnabled)
    }
    
    static func gestureSwipeRightEnabled() -> Bool {
        return boolValue(KeyGestureSwipeRightEnabled, defaul: true)
    }
    
    static func setGestureSwipeRightEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled ? 1 : 0, forKey: KeyGestureSwipeRightEnabled)
    }
    
    private static func boolValue(_ key: String, defaul: Bool) -> Bool {
        let o = UserDefaults.standard.object(forKey: key)
        guard let b = o else {
            return defaul
        }
        return (b as! Int) > 0
    }
    
    private static func doubleValue(_ key: String, defaul: Double) -> Double {
        guard let d = UserDefaults.standard.object(forKey: key) else {
            return defaul
        }
        
        return d as! Double
    }
}
