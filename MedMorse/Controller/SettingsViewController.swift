//
//  SettingsViewController.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/28/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SettingsCell"


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SettingsCellDelegate {
    
    struct Section {
        let label: String
        let items: [Settings]
    }
    
    private let dataSource = [
        Section(
            label: "Settings",
            items: [
                Settings(
                    style: .stepper,
                    title: "Words per minute",
                    units: "wpm",
                    getValue: Prefs.wpm,
                    setValue: { (d) in
                        Prefs.setWpm(d)
                        setWpm()
                    }
                ),
                Settings(
                    style: .expand,
                    title: "Advanced",
                    units: "",
                    getValue: { () -> Double in return 0.0 },
                    setValue: { (d) in }
                ),
                Settings(
                    style: .sw,
                    title: "Farnsworth Spacing",
                    units: "",
                    hidden: true,
                    getValue: { () -> Double in
                        return Prefs.farnsworthEnabled() ? 1 : 0
                    },
                    setValue: { (d) in
                        Prefs.setFarnsworthEnabled(d > 0)
                        setWpm()
                    }
                ),
                Settings(
                    style: .stepper,
                    title: "Dash",
                    units: "seconds",
                    hidden: true,
                    getValue: Prefs.dashDuration,
                    setValue: Prefs.setDashDuration),
                Settings(
                    style: .stepper,
                    title: "Character",
                    units: "seconds",
                    hidden: true,
                    getValue: Prefs.characterPause,
                    setValue: Prefs.setCharacterPause),
                Settings(
                    style: .stepper,
                    title: "Word",
                    units: "seconds",
                    hidden: true,
                    getValue: Prefs.wordPause,
                    setValue: Prefs.setWordPause)
            ]
        ),
        Section(
            label: "Force Touch",
            items: [
                Settings(
                    style: .sw,
                    title: "Enabled",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.forceTouchEnabled() ? 1 : 0
                    },
                    setValue: { (d) in
                        Prefs.setForceTouchEnabled(d > 0)
                    }),
                Settings(
                    style: .stepper,
                    title: "Sensitivity",
                    units: "%",
                    getValue: Prefs.forceTouchSensitivity,
                    setValue: Prefs.setForceTouchSensitivity)
             ]
        ),
        Section(
            label: "Feedback",
            items: [
                Settings(
                    style: .sw,
                    title: "Sound",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.feedbackSoundEnabled() ? 1 : 0
                    },
                    setValue: { (d) in
                        Prefs.setFeedbackSoundEnabled(d > 0)
                    }
                ),
                Settings(
                    style: .stepper,
                    title: "Frequency",
                    units: "Hz",
                    getValue: Prefs.feedbackSoundFrequency,
                    setValue: Prefs.setFeedbackSoundFrequency
                ),
                Settings(
                    style: .sw,
                    title: "Vibrate",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.feedbackVibrateEnabled() ? 1 : 0
                    },
                    setValue: { (d) in
                        Prefs.setFeedbackVibrateEnabled(d > 0)
                    }
                ),
                Settings(
                    style: .sw,
                    title: "Flash",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.feedbackFlashEnabled() ? 1 : 0
                    },
                    setValue: { (d) in
                        Prefs.setFeedbackFlashEnabled(d > 0)
                    }
                ),
                Settings(
                    style: .sw,
                    title: "Flashlight",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.feedbackTorchEnabled() ? 1 : 0
                    },
                    setValue: { (d) in
                        Prefs.setFeedbackTorchEnabled(d > 0)
                    }
                )
            ]
        ),
        Section(
            label: "Gestures",
            items: [
                Settings(
                    style: .sw,
                    title: "Shake to Clear",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.gestureShakeEnabled() ? 1 : 0
                },
                    setValue: { (d) in
                        Prefs.setGestureShakeEnabled(d > 0)
                }),
                Settings(
                    style: .sw,
                    title: "Swipe Left Backspace",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.gestureSwipeLeftEnabled() ? 1 : 0
                },
                    setValue: { (d) in
                        Prefs.setGestureSwipeLeftEnabled(d > 0)
                }),
                Settings(
                    style: .sw,
                    title: "Swipe Right Space",
                    units: "",
                    getValue: { () -> Double in
                        return Prefs.gestureSwipeRightEnabled() ? 1 : 0
                },
                    setValue: { (d) in
                        Prefs.setGestureSwipeRightEnabled(d > 0)
                })
            ]
        ),
    ]

    private lazy var toolBar: UIToolbar = {
           let toolBar = UIToolbar(frame:CGRect(
               x: 0, y: UIApplication.shared.windows[0].safeAreaInsets.top / 2, width: view.frame.width, height: 45))
           
           toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
           toolBar.backgroundColor = .black
           toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
           toolBar.tintColor = .white

           let clear = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeTap))
           
           toolBar.items = [clear]
           return toolBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        tableView.frame.origin.y = toolBar.frame.size.height
        tableView.frame.size.height = tableView.frame.size.height - tableView.frame.origin.y - self.tableView(tableView, heightForHeaderInSection: 0) / 2
        
        tableView.backgroundColor = .black
        tableView.separatorColor = .black

        tableView.allowsSelection = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.cellLayoutMarginsFollowReadableWidth = true
        return tableView
    }()
    
    private static func setWpm() {
        let wpm = Int(Prefs.wpm())
        let dur = Prefs.farnsworthEnabled() ? MorseCoder.farnsworth(wpm: wpm) : MorseCoder.paris(wpm: wpm)
        Prefs.setDashDuration(Double(dur.dahDuration) / 1000)
        Prefs.setCharacterPause(Double(dur.charDuration) / 1000)
        Prefs.setWordPause(Double(dur.wordDuration) / 1000)
    }
    
    // MARK: UIViewController Methods
    override func loadView() {
        super.loadView()
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(tableView)
        view.addSubview(toolBar)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // HACK! Callback to populate morseview settings
        self.presentingViewController?.viewWillAppear(animated)
    }
    
    @objc func closeTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TableView DataSource
    func numberOfSections(in: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingsCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        cell.settings = dataSource[indexPath.section].items[indexPath.row]
        cell.delegate = self
        cell.isHidden = cell.settings.hidden && advancedHidden
        return cell
    }
    
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let s = dataSource[section]
        let view = UIView()
        view.backgroundColor = .black
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 28, weight: .light)
        title.textColor = .white
        title.text = s.label
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        // title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let settings = dataSource[indexPath.section].items[indexPath.row]
        if settings.style == .expand {
            return 16
        }
        return settings.hidden && advancedHidden ? 0.0 : tableView.rowHeight
    }
    
    // MARK: SettingsCellDelegate
    func wpmUpdated() {
        tableView.reloadData()
    }
    
    private var advancedHidden = true
    private var advancedIndexPaths = [
        IndexPath(row: 2, section: 0),
        IndexPath(row: 3, section: 0),
        IndexPath(row: 4, section: 0),
        IndexPath(row: 5, section: 0)
    ]
    func expandTapped() {
        advancedHidden = !advancedHidden
        self.tableView.reloadRows(at: advancedIndexPaths, with: UITableView.RowAnimation.fade)
    }
}

