//
//  Playlist.swift
//  Moodify
//
//  Created by Paul Shamoon on 11/5/24.
//

/*
 A "Playlist" object to contain detail information about a specific users playlist.
 
 Created By: Paul Shamoon
 */
struct Playlist: Identifiable, Codable {
    var id: UUID = UUID()
    var mood: String
    var profileId: UUID
    var songs: [Song]
    var dateCreated: Date = Date()

    init(mood: String, profileId: UUID, songs: [Song], dateCreated: Date = Date()) {
        self.mood = mood
        self.profileId = profileId // Directly assign the profileId passed in
        self.songs = songs
        self.dateCreated = dateCreated
    }
}
