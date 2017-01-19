//
//  AudioPlayManager.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 11/11/16.
//  Copyright © 2016 Persistent. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayManager: NSObject, AVAudioPlayerDelegate {
    private var playarray: [NSData] = []
    private var callbacks: [((Bool) -> Void)?] = []
    private var audioPlayer: AVAudioPlayer? = nil
    
    var audioSource: AVAudioPlayer?{
        get{
            return audioPlayer
        }
    }
    
    func playFile(fileName: NSString, type:NSString)
    {
        let url = URL.init(fileURLWithPath: Bundle.main.path(
            forResource: fileName as String,
            ofType: type as String)!)
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
    }
    
    func playWaveData(data: NSData, fileType: String = "wav", callback: ((Bool) -> Void)? = nil) {
        callbacks.append(callback)
        
        let playing = audioPlayer?.isPlaying ?? false
        
        if(!playing) {
            playWaveDataNow(data: data)
        } else {
            playarray.append(data)
        }
    }
    
    func playWaveFile(filePath: String, fileType: String = "wav", callback: ((Bool)->Void)? = nil) {
        let audioFilePath = Bundle.main.path(forResource: filePath, ofType: fileType)
        
        if audioFilePath != nil {
            playWaveData(data: NSData(contentsOfFile: audioFilePath!)!, fileType: fileType, callback: callback)
        } else {
            print("audio file is not found")
        }
    }
    
    func playWaveDataNow(data: NSData, fileType: String = "wav") {
        
        self.setDefaultToSpeaker()
        
        do {
            let mutableData = NSMutableData(data: data as Data)
            if fileType == "wav" {
                MediaUtil.repairWAVHeader(data: mutableData)
            }
            audioPlayer = try AVAudioPlayer(data: mutableData as Data)
            audioPlayer?.delegate = self
            audioPlayer!.isMeteringEnabled = true
            audioPlayer!.prepareToPlay()
            audioPlayer!.volume = 1.0
            audioPlayer!.play()
            print("playing")
        } catch {
            print("In catch")
        }
    }
    
    func setDefaultToSpeaker()
    {
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
            
        }
        catch
        {
            
        }
    }
    
    func setVolume(volume: Float) {
        if audioPlayer != nil {
            audioPlayer?.volume = volume
        }
    }
    
    func stop() {
        if audioPlayer != nil {
            audioPlayer?.stop()
        }
    }
    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        // play next audio in queue if it exists
        if(!playarray.isEmpty) {
            let wav = playarray[0]
            playarray.remove(at: 0)
            playWaveDataNow(data: wav)
        }
        
        if(callbacks.count > 0)
        {
            if let callback = callbacks.remove(at: 0) {
                callback(flag)
            }
        }
    }
    
}
