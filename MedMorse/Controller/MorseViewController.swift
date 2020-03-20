//
//  ViewController.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/26/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import UIKit
import AVFoundation

class MorseViewController: UIViewController, MorseViewDelegate {
    
    var morseView: MorseView!
    private var textView: UITextView!
    private var codeView: UITextView!
    private var toolBar: UIToolbar!

    private var feedbackFlashEnabled = false
    private var feedbackSoundEnabled = false
    private var feedbackTorchEnabled = false
    private var feedbackEnabled = false
    
    private let impactFeedbackGenerator: UIImpactFeedbackGenerator = {
        let g = UIImpactFeedbackGenerator()
        g.prepare()
        return g
    }()
    
    private lazy var toneGenerator: ToneGenerator = {
        return ToneGenerator()
    }()
    
    private var flashView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var gestureShakeEnabled         = true
    private var gestureSwipeLeftEnabled     = true
    private var gestureSwipeRightEnabled    = true

    private var decodedIndex = 0
    
    // MARK: UIViewController Methods
    override func loadView() {
        super.loadView()
        morseView = MorseView(frame: UIScreen.main.bounds)
        morseView.delegate = self
        setupTextView()
        setupCodeView()
        setupToolbar()
        setupGestures()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(morseView)
        view.addSubview(textView)
        view.addSubview(codeView)
        view.addSubview(toolBar)
        view.addSubview(flashView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // HACK! Callback from closed settings
        morseView.durationDash = Prefs.dashDuration()
        morseView.wordPause = Prefs.wordPause()
        morseView.characterPause = Prefs.characterPause()
        morseView.forceTouchEnabled = Prefs.forceTouchEnabled()
        morseView.forceTouchSensitivity = CGFloat(Prefs.forceTouchSensitivity())
        
        self.feedbackEnabled = Prefs.feedbackVibrateEnabled()
        self.feedbackFlashEnabled = Prefs.feedbackFlashEnabled()
        self.feedbackTorchEnabled = Prefs.feedbackTorchEnabled()
        if self.feedbackTorchEnabled {
            Flashlight.setTorch(on: false)
        }
        self.feedbackSoundEnabled = Prefs.feedbackSoundEnabled()
        if self.feedbackSoundEnabled {
            self.toneGenerator.frequency = Prefs.feedbackSoundFrequency()
        }
        
        self.gestureShakeEnabled = Prefs.gestureShakeEnabled()
        self.gestureSwipeLeftEnabled = Prefs.gestureSwipeLeftEnabled()
        self.gestureSwipeRightEnabled = Prefs.gestureSwipeRightEnabled()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake && gestureShakeEnabled {
            clearTapped()
        }
    }

    // MARK: Toolbar
    private func setupToolbar() {
        
        toolBar = UIToolbar(frame:CGRect(
            x: 0, y: UIApplication.shared.windows[0].safeAreaInsets.top, width: morseView.frame.width, height: 45))
        
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.backgroundColor = .clear
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolBar.tintColor = .white

        let clear           = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(clearTapped))
        let flexibleSpace   = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        let share           = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        let help            = UIBarButtonItem(title: NSString(string: "?") as String, style: .plain, target: self, action: #selector(helpTapped))

        let settings        = UIBarButtonItem(title: NSString(string: "\u{2699}\u{0000FE0E}") as String, style: .plain, target: self, action: #selector(settingsTapped))
        
        
        // TODO: .SFUI-Ultralight
        let font = UIFont.systemFont(ofSize: 30, weight: .ultraLight)
        let attributes = [NSAttributedString.Key.font : font]
        settings.setTitleTextAttributes(attributes, for: .normal)
        settings.setTitleTextAttributes(attributes, for: .selected)

        let hfont = UIFont.systemFont(ofSize: 30, weight: .light)
        let hattributes = [NSAttributedString.Key.font : hfont]
        help.setTitleTextAttributes(hattributes, for: .normal)
        help.setTitleTextAttributes(hattributes, for: .selected)

        toolBar.items = [clear, flexibleSpace, share, flexibleSpace, help, settings]
    }
    
    @objc func settingsTapped() {
        // TODO: Make delegate and remove the viewWillAppear hack
        let settings = SettingsViewController()
        self.present(settings, animated: true, completion: nil)
    }
    
    @objc func helpTapped() {
        self.present(HelpViewController(), animated: true, completion: nil)
    }
    
    @objc func clearTapped() {
        textView.text = ""
        positionCodeView()
    }
    
    @objc func shareTapped(_ sender: UIBarButtonItem) {
        if textView.text == "" {
            return
        }
        let items = [textView.text!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            ac.popoverPresentationController?.barButtonItem = sender
        }
        present(ac, animated: true)
    }
    
    // MARK: Gestures
    private func setupGestures() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        left.direction = .left
        view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        right.direction = .right
        view.addGestureRecognizer(right)
    }
    
    @objc func swipeLeft() {
        if gestureSwipeLeftEnabled {
            if textView.text.count > 0 {
                textView.text = String(textView.text.prefix(textView.text.count - 1))
                positionCodeView()
            }
            codeView.text = ""
        }
    }
    
    @objc func swipeRight() {
        if gestureSwipeRightEnabled {
            textView.text += " "
            codeView.text = ""
            positionCodeView()
        }
    }
    
    // MARK: View Setup
    private func setupTextView() {
        let x = morseView.frame.origin.x + morseView.frame.size.width * 0.1
        let y = morseView.frame.origin.y + morseView.frame.size.height * 0.1
        let width = morseView.frame.size.width - (x * 2)
        let height = morseView.frame.size.height - (y * 2)
        let textFrame = CGRect(x: x, y: y, width: width, height: height)
        
        textView = UITextView(frame: textFrame)
        textView.textColor = .white
        textView.backgroundColor = Prefs.textViewColor
        textView.isUserInteractionEnabled = false
        textView.allowsEditingTextAttributes = false
        textView.isScrollEnabled = true
        textView.font = .systemFont(ofSize: 50.0, weight: .light)
        textView.textAlignment = .center
    }

    private func setupCodeView() {

        codeView = UITextView(frame: CGRect(
            origin: codeViewOrigin(),
            size: CGSize(width: morseView.frame.size.width,
                         height: Prefs.codeFontSize)))

        codeView.textColor = .white
        codeView.backgroundColor = Prefs.codeViewColor
        codeView.isUserInteractionEnabled = false
        codeView.allowsEditingTextAttributes = false
        codeView.font = .systemFont(ofSize: Prefs.codeFontSize, weight: .light)
        codeView.textAlignment = .center
    }
    
    // MARK: CodeView positioning
    private func codeViewOrigin() -> CGPoint {
        return CGPoint(x: morseView.frame.origin.x,
                       y: (morseView.frame.size.height / 2) - (Prefs.codeFontSize / 2))
    }
    
    // check if the text has overlapped the code and move code view lower if so.
    // or readjust it back up if clear/backspace
    private func positionCodeView() {
        let s = textView.frame.origin.y + textView.contentSize.height
        let v = codeView.frame.origin.y
        if s - (Prefs.codeFontSize / 2) > v {
            // move down
            codeView.frame.origin.y = s
        } else if v > s + (Prefs.codeFontSize / 2) {
            // move up
            let oy = codeViewOrigin().y
            if s > oy {
                codeView.frame.origin.y = s
            } else {
                codeView.frame.origin.y = oy
            }
        }
        
        if codeView.frame.origin.y + codeView.frame.size.height > UIScreen.main.bounds.size.height {
            // don't scoot down if it would go off screen
            codeView.frame.origin.y = v
        }
    }

    // MARK: MorseView Delegate Methods
    func onCharacter(character: String) {
        textView.insertText(character)
        codeView.text = ""
        positionCodeView()
    }

    func onWordBreak() {
        print("Word Break")
        textView.insertText(" ")
    
        // scroll down textView if its exceeded the screen
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count, 0))
    }
    
    func onCode(code: Character) {
        if feedbackEnabled {
            impactFeedbackGenerator.impactOccurred(intensity: code == "•" ? 0.5 : 5.0)
            impactFeedbackGenerator.prepare()
        }
        codeView.text.append(code)
    }
    
    func onTapBegan() {
        if feedbackSoundEnabled {
            toneGenerator.play()
        }
        if feedbackFlashEnabled {
            flashView.backgroundColor = .white
        }
        if feedbackTorchEnabled {
            Flashlight.setTorch(on: true)
        }
    }
    
    func onTapEnded() {
        if feedbackSoundEnabled {
            // TODO: How to stop crack?
            toneGenerator.stop()
        }
        if feedbackFlashEnabled {
            flashView.backgroundColor = .clear
        }
        if feedbackTorchEnabled {
            Flashlight.setTorch(on: false)
        }
    }
    
    func onTapCanceled() {
        onTapEnded()
    }
}

