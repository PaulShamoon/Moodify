//
//  Queue.swift
//  Moodify
//
//  Created by Paul Shamoon on 10/29/24.
//

/*
 A "Song" object to contain detail information about a song.
 
 Created By: Paul Shamoon
 */
struct Song: Identifiable {
    var id = UUID()
    var trackName: String
    var albumName: String
    var artistName: String
    var songURI: String
}
