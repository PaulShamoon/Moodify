//
//  PlaylistManagerTests.swift
//  PlaylistManagerTests
//
//  Created by Paul Shamoon on 11/18/24.
//

import XCTest
@testable import Moodify


/*
 Class to test all the methods of the PlaylistManager
 
 NOTE: We are not testing methods that require access to the Spotify appRemote
 
 Created By: Paul Shamoon
 */
class PlaylistManagerTests: XCTestCase {
    var queueManager: QueueManager!
    var playlistManager: PlaylistManager!
    var spotifyController: SpotifyController!
    
    
    /*
     Method to setup all the data we
     need before each test runs
     
     Created By: Paul Shamoon
     */
    override func setUp() {
        super.setUp()
        queueManager = QueueManager()
        spotifyController = SpotifyController()
        
        playlistManager = PlaylistManager(queueManager: queueManager, spotifyController: spotifyController)
        playlistManager.playlists = SetupTestData.shared.playlists
    }
    
    
    /*
     Method to tear down preset data
     after the completion of each test
     
     Created By: Paul Shamoon
     */
    override func tearDown() {
        // Clean up after each test
        playlistManager = nil
        super.tearDown()
    }
     
    
    /*
     Method to test that the updateOrCreatePlaylist method of the playlistManager
     behaves as expected and can propperly UPDATE a playlist
     
     Created By: Paul Shamoon
     */
    func testUpdatePlaylist() {
        let originalPlaylist = playlistManager.playlists[0]
        let profile1 = SetupTestData.shared.profile1
        let updatedSongs = originalPlaylist.songs + [SetupTestData.shared.song3]
        
        // Update the originalPlaylists songs with updatedSongs
        playlistManager.updateOrCreatePlaylist(
            mood: originalPlaylist.mood,
            profile: profile1,
            songs: updatedSongs
        )
        
        // Get the updated playlist
        let updatedPlaylist = playlistManager.playlists.first(where:
            { $0.profileId == profile1.id && $0.mood == originalPlaylist.mood }
        )

        // Ensure that updatedPlaylist exists
        XCTAssertNotNil(updatedPlaylist, "Updated playlist does not exist")
        
        // Ensure that the updatedPlaylists songs equals updatedSongs
        XCTAssertEqual(updatedPlaylist?.songs, updatedSongs, "updatedPlaylists songs do not match updatedSongs")
        
        // Ensure that updatedPlaylists songs do not equal the originalPlaylists songs
        XCTAssertNotEqual(updatedPlaylist?.songs, originalPlaylist.songs, "updatedPlaylists songs and originalPlaylists songs are the same")
    }
    
    
    /*
     Method to test that the updateOrCreatePlaylist method of the playlistManager
     behaves as expected and can propperly CREATE a playlist
     
     Created By: Paul Shamoon
     */
    func testCreatePlaylist() {
        let original_playlists = playlistManager.playlists
        let profile2 = SetupTestData.shared.profile2
        let song1 = SetupTestData.shared.song1
        let song2 = SetupTestData.shared.song2
        let song3 = SetupTestData.shared.song3
        
        // Create a new playlist
        playlistManager.updateOrCreatePlaylist(
            mood: "happy",
            profile: profile2,
            songs: [song1, song2, song3]
        )
        
        // Get the newly created playlist
        let createdPlaylist = playlistManager.playlists.first(where:
            { $0.profileId == profile2.id && $0.mood == "happy" }
        )
        
        // Ensure that createdPlaylist exists
        XCTAssertNotNil(createdPlaylist, "The created playlist does not exist")
        
        // Ensure that the total amount of playlists are now 3
        XCTAssertEqual(playlistManager.playlists.count, 3, "Total amount of playlists should be 3")
        
        // Ensure that original_playlists does not equal the playlistManagers playlists since we created a new playlist
        XCTAssertNotEqual(original_playlists, playlistManager.playlists, "Playlists should contain the newly created playlist")
    }
    
    
    /*
     Method to test that the getUsersPlaylists method of the playlistManager
     behaves as expected and can propperly get all of a users playlists
     
     Created By: Paul Shamoon
     */
    func testGetUsersPlaylists() {
        // Get profile1's playlists
        let profile1_playlists = playlistManager.getUsersPlaylists(profile: SetupTestData.shared.profile1)
        
        // Ensure that user only has 1 playlist
        XCTAssertEqual(profile1_playlists.count, 1, "Profile1 should only have 1 playlist")

        // Ensure that the returned playlist equals playlist1
        XCTAssertEqual(SetupTestData.shared.playlist1, profile1_playlists.first, "Playlist1 does not match profile1_playlist")

        // Get profile2's playlists
        let profile2_playlists = playlistManager.getUsersPlaylists(profile: SetupTestData.shared.profile2)
        
        // Ensure that user only has 1 playlist
        XCTAssertEqual(profile2_playlists.count, 1, "Profile2 should only have 1 playlist")

        // Ensure that the returned playlist equals playlist2
        XCTAssertEqual(SetupTestData.shared.playlist2, profile2_playlists.first, "Playlis2 does not match profile2_playlist")
    }
    
    
//    /*
//     Method to test that the toggleFavorite method of the playlistManager
//     behaves as expected.
//     
//     If the passed in Song objects isFavorited attribute is set to false, then calling
//     toggleFavorite should set it to true and move the favorited song to the begining of
//     the playlists songs
//     
//     If the passed in song objects isFavorited attribute is set to true, then calling
//     toggleFavorite should set it to false and move the unfavorited song underneath the last
//     favorited song OR to the bottom of the songs if there are no favorited song in the playlist
//     
//     Created By: Paul Shamoon
//     */
//    func testToggleFavorite() {
//        var playlist1 = playlistManager.playlists[0]
//        let song2 = playlist1.songs[1]
//        
//        // Set song2 to be favorited
//        playlistManager.toggleFavorite(playlist: &playlist1, song: song2)
//        
//        // Retrieve the updated playlist from playlistManager
//        var updated_playlist = playlistManager.playlists[0]
//        
//        // Ensure the first element in updated_playlists is song2
//        XCTAssertTrue(updated_playlist.songs.first == song2, "The first song in updated_playlist is not song2, it was \(String(describing: updated_playlist.songs.first?.trackName))")
//        
//        
//        // Ensure updated_playlists song2 is favorited
//        XCTAssertTrue(updated_playlist.songs.first?.isFavorited ?? false, "song2 is not favorited")
        
//        // Set song2 to be unfavorited
//        playlistManager.toggleFavorite(playlist: &playlist1, song: song2)
//        
//        
//        // Retrieve the updated playlist from playlistManager
//        updated_playlist = playlistManager.playlists[0]
//        
//        // Ensure updated_playlists song2 is not favorited
        
//    }
    
    
    /*
     Method to test that the removeSongFromPlaylist method of the playlistManager
     behaves as expected and can propperly remove a Song object from a playlist
     
     Created By: Paul Shamoon
     */
    func testRemoveSongFromPlaylist() {
        var original_playlist = playlistManager.playlists[0]
        let song1 = original_playlist.songs[0]
        
        // Remove song1 from original_playlist
        playlistManager.removeSongFromPlaylist(playlist: &original_playlist, song: song1)
        
        // Retrieve the updated playlist from playlistManager
        let updated_playlist = playlistManager.playlists[0]

        // Assert that song1 is no longer in updatedPlaylist1 songs
        XCTAssertFalse(updated_playlist.songs.contains(song1), "updated_playlist should not contain song1 after removal")
        
        // Assert that updatedPlaylist1 song count is correct
        XCTAssertEqual(updated_playlist.songs.count, 1, "updated_playlist should only have 1 song after removal")
    }
}

