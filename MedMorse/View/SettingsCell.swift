//
//  SettingsCell.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/29/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate {
    func wpmUpdated()
    func expandTapped()
}

class SettingsCell: UITableViewCell {
    
    var delegate:SettingsCellDelegate?

    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.backgroundColor = .clear
        stepper.setDecrementImage(stepper.decrementImage(for: .normal), for: .normal)
        stepper.setIncrementImage(stepper.incrementImage(for: .normal), for: .normal)
        stepper.tintColor = .white
        return stepper
    }()
    
    private let sw: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .lightGray
        return sw
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        // label.font = .systemFont(ofSize: 12, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var st: Settings?
    public var settings: Settings {
        set(s) {
            self.st = s
            self.selectionStyle = .none
            self.backgroundColor = .black
            
            self.textLabel!.font = .systemFont(ofSize: 20, weight: .light)
            self.textLabel!.textColor = .white
            self.textLabel!.text = s.title
            self.textLabel!.isHidden = false

            var detailFontSize:CGFloat = 12
            if s.units == "wpm" {
                detailFontSize = 16
            }
            self.detailLabel.font = .systemFont(ofSize: detailFontSize, weight: .light)
            self.detailLabel.textColor = .white
            if s.units == "" {
                self.detailLabel.isHidden = true
            } else {
                self.detailLabel.isHidden = false
                setDetailLabelText(s.getValue())
            }
            self.detailLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(detailTapped))
            self.detailLabel.addGestureRecognizer(tap)
            
            switch s.style {
            case .stepper:
                if s.units == "wpm" {
                    stepper.stepValue = 1.0
                    stepper.maximumValue = 80.0
                    stepper.minimumValue = 1.0
                } else if s.units == "Hz" {
                    stepper.stepValue = 50.0
                    stepper.maximumValue = 2000.0
                    stepper.minimumValue = 50.0
                } else {
                    stepper.stepValue = 0.050
                    stepper.minimumValue = 0.050
                    stepper.maximumValue = 10.0
                }
                stepper.value = s.getValue()
                stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
                self.accessoryView = stepper
            case .sw:
                sw.isOn = s.getValue() > 0 ? true : false
                sw.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
                self.accessoryView = sw
            case .expand:
                self.accessoryView = nil
                self.textLabel?.isHidden = true
                self.detailLabel.font = .systemFont(ofSize: 14, weight: .light)
                self.detailLabel.textColor = .red
                self.detailLabel.isHidden = false
                self.detailLabel.text = s.title
            }
        }
        get {
            return st!
        }
    }
    
    // MARK: - Init
       
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(detailLabel)
        detailLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        detailLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Callbacks
    
    @objc func switchChanged() {
        st!.setValue(sw.isOn ? 1 : 0)
        if st!.title.starts(with: "Farnsworth") {
            delegate?.wpmUpdated()
        }
    }
    
    @objc func stepperChanged() {
        st!.setValue(stepper.value)
        setDetailLabelText(stepper.value)
        if st!.units == "wpm" {
            delegate?.wpmUpdated()
        }
    }
    
    @objc func detailTapped() {
        if st!.style == .expand {
            delegate?.expandTapped()
        }
    }
    
    private func setDetailLabelText(_ value: Double) {
        switch st!.units {
        case "%":
            self.detailLabel.text = String(format: "%d %@", Int(value * 100), st!.units)
        case "Hz":
            self.detailLabel.text = String(format: "%d %@", Int(value), st!.units)
        case "wpm":
            self.detailLabel.text = String(format: "%d", Int(value))
        default:
            self.detailLabel.text = String(format: "%.2f %@", value, st!.units)
        }
    }
}
