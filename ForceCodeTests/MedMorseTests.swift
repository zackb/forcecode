//
//  MedMorseTests.swift
//  MedMorseTests
//
//  Created by Zack Bartel on 2/26/20.
//  Copyright © 2020 Zack Bartel. All rights reserved.
//

import XCTest
@testable import MedMorse

class MedMorseTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWpm() {
        let d = MorseCoder.farnsworth(wpm:8)
        XCTAssertEqual(150, d.ditDuration)
        XCTAssertEqual(450, d.dahDuration)
        XCTAssertEqual(1145, d.charDuration)
        XCTAssertEqual(2671, d.wordDuration)
        
        let dd = MorseCoder.paris(wpm: 8)
        XCTAssertEqual(150, dd.ditDuration)
        XCTAssertEqual(dd.ditDuration * 3, dd.dahDuration)
        XCTAssertEqual(dd.ditDuration * 3, dd.charDuration)
        XCTAssertEqual(dd.ditDuration * 7, dd.wordDuration)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
