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
            AudioPlayer().navigationTitle("Music Player")
        }
    }
}

struct AudioPlayer: View {
    @State var data : Data = .init(count:0)
    @State var title:String = ""
    @State var sliderValue:Float = 0
    @State var player:AVAudioPlayer!
    @State var playing:Bool = false
    @State var width:CGFloat = 0.0
    @State var playList = ["ambient-classical-guitar-144998","smack-that-matrika-main-version-16158-01-35"]
    @State var curruntSong = 0
    @State var finished  = false
    @State var aduioPlayerDelegate = AVAudioDelegate()
   
    
    var body: some View {
        VStack(spacing: 20){
            Image(uiImage: self.data.count == 0 ? UIImage(systemName:"music.note")! :  UIImage(data: self.data)! )
               
                .resizable()
                .frame(width: self.data.count == 0 ? 250 : nil,height:250 )
            Text(title.isEmpty ? "Title gose here " : "" ).font(.title).padding(.top)
                .cornerRadius(15, antialiased: true)
            ZStack(alignment:.leading){
                Capsule().fill(Color.black.opacity(0.08)).frame(height: 8)
                Capsule().fill(Color.red).frame(width: self.width,height: 8).gesture(DragGesture().onChanged({ (value) in
                    let x = value.location.x
                    self.width = x
                    
                }).onEnded({ (value) in
                    let x = value.location.x
                    let screen = UIScreen.main.bounds.width - 30
                    let precent = x / screen
                    self.player.currentTime  = Double(precent) * self.player.duration
                }))
            }
            

            
            HStack(spacing:UIScreen.main.bounds.width / 5-30 ){
                Button(action: {
                    
                    if curruntSong > 0{
                        self.curruntSong -= 1
                        self.changeSong()
                    }
                }){
                    Image(systemName: "backward.fill").font(.title)
                }
                
                Button(action: {
                    
                    self.player.currentTime -= 15
                }){
                    Image(systemName: "gobackward.15").font(.title)
                }
                Button(action: {
                    
                    if self.player.isPlaying {
                        self.player.pause()
                        self.playing =  false
                    } else {
                        if self.finished{
                            self.player.currentTime = 0
                            self.width = 0
                            self.finished = false
                        }
                        self.player?.play()
                        self.playing =  true
                    }
                }){
                    Image(systemName:  self.playing && !self.finished ? "pause.fill" :  "play.fill").font(.title)
                }
                Button(action: {
                    let goforward =   self.player.currentTime + 15
                    
                    if goforward < self.player.duration {
                        self.player.currentTime = goforward
                    }
                    
                }){
                    Image(systemName: "goforward.15").font(.title)
                }
                Button(action: {
                    if self.playList.count - 1 !=  self.curruntSong{
                        self.curruntSong += 1
                        self.changeSong()
                    }
                }){
                    Image(systemName: "forward.fill").font(.title)
                }
            }.padding(.top,30)
                .foregroundColor(.black)
        }.onAppear {
            guard let url = Bundle.main.path(forResource: playList[curruntSong], ofType: "mp3") else {
                return
            }
            
            do {
                let asset = try AVAsset(url: URL(fileURLWithPath: url))
                self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
                self.player.delegate = aduioPlayerDelegate
                self.player.prepareToPlay()
                getData()
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                    if self.player.isPlaying{
                        let screen  = UIScreen.main.bounds.width - 30
                        let value =  self.player.currentTime / self.player.duration
                        self.width = screen * CGFloat(value)
                        
                    }
                }
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) {(_) in
                    self.finished = true
                    
                    
                }
            } catch {
                // Handle the error here, for example:
                print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
            }
        }
    }
    
    func getData(){
        let asset = AVAsset(url: (self.player?.url)!)
        asset.loadValuesAsynchronously(forKeys: ["commonMetadata"]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: "commonMetadata", error: &error)
            
            switch status {
            case .loaded:
                for i in asset.commonMetadata{
                    if i.commonKey?.rawValue == "artwork"{
                        let data = i.value as! Data
                        self.data  = data
                    }

                    if i.commonKey?.rawValue == "title"{
                        let data = i.value as! String
                        self.title = data
                    }
                }
            case .failed:
                print("Failed to load metadata: \(error?.localizedDescription ?? "Unknown error")")
            case .cancelled:
                print("Loading metadata was cancelled.")
            default:
                break
            }
        }
    }
    
    func changeSong(){
        guard let url = Bundle.main.path(forResource: playList[curruntSong], ofType: "mp3") else {
            return
        }
        
        do {
            let asset = try AVAsset(url: URL(fileURLWithPath: url))
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
            self.player.delegate = aduioPlayerDelegate
            self.data =  .init(count: 0)
            self.title = ""
            self.player.prepareToPlay()
            getData()
            
            self.playing = true
            self.width = 0
            self.finished = false
            
            self.player.play()
            
        } catch {
            // Handle the error here, for example:
            print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
        }
    }
}

class AVAudioDelegate : NSObject, AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name:NSNotification.Name("Finish"), object: nil)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}