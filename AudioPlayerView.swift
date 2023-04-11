//
//  AudioPlayerView.swift
//  AudioPlayer
//
//  Created by Abdalla Elnajjar on 2023-04-10.
//

import SwiftUI
import AVKit

struct AudioPlayerView: View {
    @State public  var playList = []
    @State public var currentSong = 0
    
    @State private var data : Data = .init(count:0)
    @State private var title:String = ""
    @State private var sliderValue:Float = 0
    @State private var player:AVAudioPlayer!
    @State private var playing:Bool = false
    @State private var width:CGFloat = 0.0
    @State private var finished  = false
    @State private var audioPlayerDelegate = AVAudioDelegate()
    
    
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
                    
                    if currentSong > 0{
                        self.currentSong -= 1
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
                    if self.playList.count - 1 !=  self.currentSong{
                        self.currentSong += 1
                        self.changeSong()
                    }
                }){
                    Image(systemName: "forward.fill").font(.title)
                }
            }.padding(.top,30)
                .foregroundColor(.black)
        }.onAppear {
            
            guard let url = Bundle.main.path(forResource:playList[currentSong] as? String, ofType: "mp3") else {
                return
            }
            
            do {

                self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
                self.player.delegate = audioPlayerDelegate
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
        guard let url = Bundle.main.path(forResource: playList[currentSong] as? String, ofType: "mp3") else {
            return
        }
        
        do {
            let asset = try AVAsset(url: URL(fileURLWithPath: url))
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
            self.player.delegate = audioPlayerDelegate
            self.data =  .init(count: 0)
            self.title = ""
            self.player.prepareToPlay()
            getData()
            
            self.playing = true
            self.width = 0
            self.finished = false
            
            self.player.play()
            
        } catch {
            print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
        }
    }
}

class AVAudioDelegate : NSObject, AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name:NSNotification.Name("Finish"), object: nil)
    }
}


struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
    }
}
