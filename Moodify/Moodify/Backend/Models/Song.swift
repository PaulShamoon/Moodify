//
//  Song.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/29/24.
//

/*
 A "Song" object to contain detail information about a song.
 
 Created By: Paul Shamoon
 */
struct Song: Identifiable, Codable {
    var id = UUID()
    var trackName: String
    var albumName: String
    var artistName: String
    var songURI: String
}

/*
 Extension to make Song conform to Equatable protocol to allow comparison between Song objects.
 This is needed for queue management and duplicate detection.
*/
extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.songURI == rhs.songURI
    }
}
