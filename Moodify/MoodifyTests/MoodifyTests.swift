//
//  MoodifyTests.swift
//  MoodifyTests
//
//  Created by Nazanin Mahmoudi on 9/9/24.
//

import XCTest
@testable import Moodify


/*
 Class to test all the methods of the QueueManager
 
 Created By: Paul Shamoon
 */
class QueueManagerTests: XCTestCase {
    var queueManager: QueueManager!
    var song1: Song!
    
    override func setUp() {
        super.setUp()
        queueManager = QueueManager()
        queueManager.currentQueue = SetupTestData.shared.currentQueue
    }
    
    override func tearDown() {
        // Clean up after each test
        queueManager = nil
        super.tearDown()
    }
    
    func testAddSongToQueue() {
        // Make a copy of the original queue
        let originalQueue = queueManager.currentQueue
        
        // Add song3 to the currentQueue
        let updatedQueue = queueManager.addSongToQueue(song: SetupTestData.shared.song3)
        
        // Ensure that the updatedQueue contains 3 elements
        XCTAssertEqual(updatedQueue.count, 3, "Queue should have 3 songs after adding one.")
        
        // Ensure that the last elements trackName in the updatedQueue is "song3"
        XCTAssertEqual(updatedQueue.last?.trackName, "song3", "The last song in the queue should be 'song3'.")
        
        // Ensure that originalQueue and updatedQueue are NOT equal
        XCTAssertNotEqual(originalQueue, updatedQueue, "currentQueue should not be equal to updatedQueue.")
    }
    
    func testRemoveSongsFromQueue() {
        // Make a copy of the original queue
        let originalQueue = queueManager.currentQueue
        
        // Add song3 to the currentQueue
        var updatedQueue = queueManager.addSongToQueue(song: SetupTestData.shared.song3)
        
        // Remove song1 from the currentQueue
        updatedQueue = queueManager.removeSongsFromQueue(trackURI: SetupTestData.shared.song1.songURI)
        
        
        // Ensure that the updatedQueue contains 2 elements
        XCTAssertEqual(updatedQueue.count, 2, "Queue should contain song2 and song3 after removing song1.")
        
        // Ensure that the first song in the queue is Song2
        XCTAssertEqual(updatedQueue.first, SetupTestData.shared.song2, "First song in the queue should be song2.")

        // Remove song3 from the currentQueue
        updatedQueue = queueManager.removeSongsFromQueue(trackURI: SetupTestData.shared.song3.songURI)

    
        // Ensure that the updatedQueue is empty
        XCTAssertEqual(updatedQueue.count, 0, "The updatedQueue should be empty")

        // Ensure that originalQueue and updatedQueue are NOT equal
        XCTAssertNotEqual(originalQueue, updatedQueue, "currentQueue should not be equal to updatedQueue.")
    }
    
    
}


//class testPlaylistManager: XCTest {
//    
//    func testUpdateOrCreatePlaylist() {
//        
//    }
//    
//    func testGetUsersPlaylists() {
//        
//    }
//    
//    func testToggleFavorite() {
//        
//    }
//    
//    func testRemoveSongFromPlaylist () {
//        
//    }
//}

class SetupTestData {
    static let shared = SetupTestData()

    var currentQueue: [Song] = []
    var playlists: [Playlist] = []
    
    var profile1: Profile!
    var profile2: Profile!
    
    var song1: Song!
    var song2: Song!
    var song3: Song!
    
    var playlist1: Playlist!
    var playlist2: Playlist!
    
    init() {
        // Initialize profiles
        profile1 = Profile(
            name: "user1",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -15, to: Date())!,
            favoriteGenres: ["pop", "rock"],
            hasAgreedToTerms: true,
            userPin: nil,
            personalSecurityQuestion: nil,
            securityQuestionAnswer: nil
        )

        profile2 = Profile(
            name: "user2",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -20, to: Date())!,
            favoriteGenres: ["jazz", "classical"],
            hasAgreedToTerms: true,
            userPin: nil,
            personalSecurityQuestion: nil,
            securityQuestionAnswer: nil
        )
        
        // Initialize songs
        song1 = Song(
            trackName: "song1",
            albumName: "album1",
            artistName: "artist1",
            songURI: "spotify:track:song1",
            isFavorited: false
        )
        
        song2 = Song(
            trackName: "song2",
            albumName: "album2",
            artistName: "artist2",
            songURI: "spotify:track:song2",
            isFavorited: true
        )
        
        song3 = Song(
            trackName: "song3",
            albumName: "album3",
            artistName: "artist3",
            songURI: "spotify:track:song3",
            isFavorited: false
        )
        
        // Initialize playlists
        playlist1 = Playlist(
            mood: "happy",
            profileId: profile1.id,
            songs: [song1, song2],
            dateCreated: Date(),
            genres: ["pop", "metal"]
        )
        
        playlist2 = Playlist(
            mood: "sad",
            profileId: profile2.id,
            songs: [song2, song3],
            dateCreated: Date(),
            genres: ["indie", "jazz"]
        )
        
        // Initialize currentQueue
        currentQueue = [song1, song2]
        
        // Initialize playlists
        playlists = [playlist1, playlist2]
    }
}
