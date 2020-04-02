//
//  HelpViewController.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/28/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
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
    
    // MARK: UIViewController Methods
    override func loadView() {
        super.loadView()
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let textView = UITextView(frame: UIScreen.main.bounds)
        textView.frame.origin.y = toolBar.frame.size.height + 20
        textView.frame.origin.x = 45
        textView.frame.size.height = textView.frame.size.height - textView.frame.origin.y
        textView.text = HelpViewController.quotation
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 30, weight: .light)

        view.addSubview(textView)
        view.addSubview(toolBar)
    }
    
    @objc func closeTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    static let quotation = """
    Swipes
        <– delete last symbol
        –> insert space symbol

    Shake to clear screen

    Letters
        A •-
        B -•••
        C -•-•
        D -••
        E •
        F ••-•
        G --•
        H ••••
        I ••
        J •---
        K -•-
        L •-••
        M --
        N -•
        O ---
        P •--•
        Q --•-
        R •-•
        S •••
        T -
        U ••-
        V •••-
        W •--
        X -••-
        Y -•--
        Z --••

    Numbers
        0 -----
        1 •----
        2 ••---
        3 •••--
        4 ••••-
        5 •••••
        6 -••••
        7 --•••
        8 ---••
        9 ----•

    Punctuation
        . •-•-•-
        , --••--
        ? ••--••
        ! -•-•--
        - -••••-
        / -••-•
        @ •--•-•
        ( -•--•
        ) -•--•-

    """
}
