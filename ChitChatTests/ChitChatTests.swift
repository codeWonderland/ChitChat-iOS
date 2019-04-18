//
//  ChitChatTests.swift
//  ChitChatTests
//
//  Created by Easter, Alice on 4/16/19.
//  Copyright © 2019 Easter, Alice. All rights reserved.
//

import XCTest
@testable import ChitChat

class ChitChatTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateMessage() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let message = genMessage()
        
        XCTAssert(message?._id == "5cb8beec71724862a49a3990")
        XCTAssert(message?.message == "Your hopes and dreams...")
    }
    
    func testLikeMessage() {
        let message = genMessage()
        
        message?.like(good: true)
        
        XCTAssert(message?.responded == true)
        XCTAssert(message?.likes == 1)
    }
    
    func testDislikeMessage() {
        let message = genMessage()
        
        message?.like(good: false)
        
        XCTAssert(message?.responded == true)
        XCTAssert(message?.dislikes == 2)
    }
    
    func testFailLikeMessage() {
        let message = genMessage()
        
        message?.like(good: true)
        message?.like(good: true)
        
        XCTAssert(message?.responded == true)
        XCTAssert(message?.likes == 1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    private func genMessage() -> Message? {
        return Message(json: [
            "_id": "5cb8beec71724862a49a3990",
            "client": "amelia.payne@mymail.champlain.edu",
            "date": "Thu, 18 Apr 2019 18:16:12 GMT",
            "dislikes": 1,
            "ip": "184.171.151.100",
            "likes": 0,
            "loc": [
                "0.0",
                "0.0"
            ],
            "message": "Your hopes and dreams..."
            ])

    }

}
