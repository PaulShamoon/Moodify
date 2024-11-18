//
//  SetupTestData.swift
//  Moodify
//
//  Created by Paul Shamoon on 11/17/24.
//
import XCTest
@testable import Moodify

/*
 Class
 */
class SetupTestData {
    static let shared = SetupTestData()

    var currentQueue: [Song] = []
    var playlists: [Playlist] = []
    
    var profile1: Profile
    var profile2: Profile
    var profile3: Profile

    var song1: Song
    var song2: Song
    var song3: Song
    
    var playlist1: Playlist
    var playlist2: Playlist
    
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
        
        profile3 = Profile(
            name: "user3",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -13, to: Date())!,
            favoriteGenres: ["metal", "country"],
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
            isFavorited: false
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
