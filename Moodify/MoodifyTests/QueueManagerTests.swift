//
//  QueueManagerTests.swift
//  Moodify
//
//  Created by Paul Shamoon on 11/18/24.
//

import XCTest
@testable import Moodify


/*
 Class to test all the methods of the QueueManager
 
 Created By: Paul Shamoon
 */
class QueueManagerTests: XCTestCase {
    var queueManager: QueueManager!
    
    /*
     Method to setup all the data we
     need before each test runs
     
     Created By: Paul Shamoon
     */
    override func setUp() {
        super.setUp()
        queueManager = QueueManager()
        queueManager.currentQueue = SetupTestData.shared.currentQueue
    }
    
    
    /*
     Method to tear down preset data
     after the completion of each test
     
     Created By: Paul Shamoon
     */
    override func tearDown() {
        queueManager = nil
        super.tearDown()
    }
    
    
    /*
     Method to test that the addSongToQueue method of the queueManager behaves
     as expected and can propperly add a Song object to the queue
     
     Created By: Paul Shamoon
     */
    func testAddSongToQueue() -> Void {
        // Make a copy of the original queue
        let originalQueue = queueManager.currentQueue
        let song3 = SetupTestData.shared.song3
        
        // Add song3 to the queue
        let updatedQueue = queueManager.addSongToQueue(song: song3)
        
        // Ensure that the updatedQueue contains 3 elements
        XCTAssertEqual(updatedQueue.count, 3, "updatedQueue does not have 3 songs")
        
        // Ensure that the last elements trackName in the updatedQueue is "song3"
        XCTAssertEqual(updatedQueue.last?.id, song3.id, "The last song in the queue does not equal song3")
        
        // Ensure that originalQueue and updatedQueue are NOT the same
        XCTAssertNotEqual(originalQueue, updatedQueue, "currentQueue should not be equal to updatedQueue.")
    }
    
    
    /*
     Method to test that the removeSongsFromQueue method of the queueManager
     behaves as expected and can properly remove a Song object from the queue
     
     Created By: Paul Shamoon
     */
    func testRemoveSongsFromQueue() -> Void {
        let originalQueue = queueManager.currentQueue
        let song1 = SetupTestData.shared.song1
        let song2 = SetupTestData.shared.song2
        let song3 = SetupTestData.shared.song3
        
        // Remove song1 from the currentQueue
        var updatedQueue = queueManager.removeSongsFromQueue(trackURI: song1.songURI)
        
        // Ensure that the updatedQueue contains 2 elements
        XCTAssertEqual(updatedQueue.count, 1, "updatedQueue should only contain two elements")
        
        // Ensure that the first song in the queue is Song2
        XCTAssertEqual(updatedQueue.first, song2, "First song in the queue should be song2.")

        // Add song3 to the currentQueue
        updatedQueue = queueManager.addSongToQueue(song: song3)
        
        // Remove song3 from the currentQueue
        updatedQueue = queueManager.removeSongsFromQueue(trackURI: song3.songURI)

        // Ensure that the updatedQueue is empty since removing a song from the queue removes everything in front of it
        XCTAssertEqual(updatedQueue.count, 0, "The updatedQueue should be empty")

        // Ensure that originalQueue and updatedQueue are NOT equal
        XCTAssertNotEqual(originalQueue, updatedQueue, "currentQueue should not be equal to updatedQueue.")
    }
    
    
}
