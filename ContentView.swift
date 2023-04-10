///
//  ContentView.swift
//  AudioPlayer
//
//  Created by Abdalla El Najjar on 2023-03-31.
//https://www.youtube.com/watch?v=b0bNsIT2apQ

import SwiftUI
import AVKit



struct ContentView: View {
    var body: some View {
        NavigationView {
            AudioPlayerView().navigationTitle("Music Player")
        }
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
