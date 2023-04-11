///
//  ContentView.swift
//  AudioPlayer
//
//  Created by Abdalla El Najjar on 2023-03-31.
//https://www.youtube.com/watch?v=b0bNsIT2apQ

import SwiftUI
import AVKit



struct ContentView: View {
    @State public var playList = ["ambient-classical-guitar-144998","smack-that-matrika-main-version-16158-01-35"]
    var body: some View {
        NavigationView {
            AudioPlayerView(playList: playList, currentSong: 0).navigationTitle("Music Player")
        }
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
