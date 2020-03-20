//
//  MorseTranslator.swift
//  MedMorse
//
//  Created by Zack Bartel on 2/27/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//
// Thanks: https://gist.github.com/mohayonao/094c71af14fe4791c5dd

import Foundation

struct MorseCoder {
    
    private static let DitsPerWord = 50.0 // paris

    struct Durations {
        var ditDuration:Int
        var dahDuration:Int
        var charDuration:Int
        var wordDuration:Int
    }
    
    private static let encoder = [
        "0": "-----",
        "1": ".----",
        "2": "..---",
        "3": "...--",
        "4": "....-",
        "5": ".....",
        "6": "-....",
        "7": "--...",
        "8": "---..",
        "9": "----.",
        "a": ".-",
        "b": "-...",
        "c": "-.-.",
        "d": "-..",
        "e": ".",
        "f": "..-.",
        "g": "--.",
        "h": "....",
        "i": "..",
        "j": ".---",
        "k": "-.-",
        "l": ".-..",
        "m": "--",
        "n": "-.",
        "o": "---",
        "p": ".--.",
        "q": "--.-",
        "r": ".-.",
        "s": "...",
        "t": "-",
        "u": "..-",
        "v": "...-",
        "w": ".--",
        "x": "-..-",
        "y": "-.--",
        "z": "--..",
        ".": ".-.-.-",
        ",": "--..--",
        "?": "..--..",
        "!": "-.-.--",
        "-": "-....-",
        "/": "-..-.",
        "@": ".--.-.",
        "(": "-.--.",
        ")": "-.--.-"
    ]
    
    private static let decoder = Dictionary(uniqueKeysWithValues: encoder.map({ ($1, $0) }))

    static func decode(_ text: String) -> String {
        var result = ""
        for word in text.split(separator: " ") {
            print(word)
            if let dec = decoder[String(word)] {
                result.append(dec)
            }
        }
        return result
    }

    static func paris(wpm: Int) -> Durations {
        let dit = 1200 / wpm
        return Durations(
            ditDuration:  dit,
            dahDuration:  dit * 3,
            charDuration: dit * 3,
            wordDuration: dit * 7
        )
    }
    
    // Thanks: https://github.com/wm8s/WM8S_Morse/blob/master/WM8S_Morse.cpp#L1845
    // http://www.arrl.org/files/file/Technology/x9004008.pdf
    static func farnsworth(wpm: Int) -> Durations {
        var d = paris(wpm: wpm)
        
        // at sppeds of 18 WPM and above, standard timing is used (section 2)
        if wpm >= 18 {
            return d
        }
        
        let num = (((60 * d.ditDuration)) - Int(37.2 * Double(wpm))) * 1000
        let den = (d.ditDuration * wpm)
        let delay = num / den
        
        d.charDuration = (3 * delay) / 19
        d.wordDuration = (7 * delay) / 19
        
        return d
    }
}
