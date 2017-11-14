//
//  JokeCreatorViewController.swift
//  Joke_of_Day
//
//  Created by Xuefeng Liu on 11/11/17.
//  Copyright © 2017 Xuefeng Liu. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CloudKit

//status options
enum Status {
    case ERROR
    case SUCCESS
}

class JokeCreatorViewController: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate{

    let _publicData = CKContainer.default().publicCloudDatabase
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var _audioAvailable :Bool!
    var fileName = "userAudioFile.m4a"
    
    @IBOutlet weak var _jokeTitle: UITextField!
    
    @IBOutlet weak var _jokeContent: UITextView!
    
    @IBOutlet weak var _warningLabel: UILabel!
    
    
    @IBOutlet weak var _recordLabel: UIButton!
    
    @IBAction func _query(_ sender: UIButton) {
        queryDatabase()
    }
    
    @IBAction func _playJoke(_ sender: UIButton) {
        print("the play button is clicked")

        // change the button text when it's playing
        if sender.titleLabel?.text == "Play" {
            if PlayRecordedAudio() == Status.SUCCESS{
                sender.setTitle("Stop", for: UIControlState())
            }else{
                print("failed to play audio")
                return
            }
            
        }
        else{
            soundPlayer.stop()
            sender.setTitle("Play", for: UIControlState())
        }
    }
    
    //get the path directory for recorded audio
    func getFileDirectory() -> URL {
        print("get record audio file directory")
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        return path
    }

    //play the recorded audio
    func PlayRecordedAudio()->Status{
        
        do{
            print("play the record audio")
            soundPlayer = try AVAudioPlayer(contentsOf: getFileDirectory())
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
            soundPlayer.play()
            return Status.SUCCESS
        }catch{
            
            print("Error: soundPlayer error")
            return Status.ERROR
        }
    }
    
    //setup variable in recorder
    func setupRecorder(){
        print("set up recorder")
        do {
            //config the audio rate
            let recordSettings = [AVFormatIDKey : kAudioFormatAppleLossless,
                                  AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                  AVEncoderBitRateKey : 310000,
                                  AVNumberOfChannelsKey : 2,
                                  AVSampleRateKey : 44000.0 ] as [String : Any]
            //set the delete to sound recorder and save the audio in retrieved directory
            soundRecorder = try AVAudioRecorder(url: getFileDirectory(), settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
            
        }catch{
            print("Error: soundRecorder error!")
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _jokeTitle.text=""
        _jokeContent.text=""
        _audioAvailable=false
        //set up the recorder
        setupRecorder()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func _sendJoke(_ sender: UIButton) {
        
        if _jokeTitle.text == "" {
            _warningLabel.text="please input title"
            return
        }
        if _jokeContent.text == "" {
            _warningLabel.text="pleae input joke content"
            return
        }
        if !_audioAvailable{
            _warningLabel.text="pleae input audio"
            return
        }
        
        
        let newJoke = CKRecord(recordType: "Joke")
        newJoke["content"]=_jokeContent.text as CKRecordValue?
        newJoke["title"]=_jokeTitle.text! as CKRecordValue
        newJoke["audio"]=CKAsset(fileURL: getFileDirectory())
        newJoke["rate"] = NSNumber(value: 0)

        
        _publicData.save(newJoke){(record,error) in
            if let err = error{
                print(err)
            }
            
            guard record != nil else {
                print("saved record with note")
                return
            }
            
        }
        _audioAvailable=false
    }
    
    @IBAction func _record(_ sender: UIButton) {
        
        _audioAvailable=true
        print("the record button is clicked")
        
        if sender.titleLabel?.text == "Record"{
            self._recordLabel.titleLabel?.text = "Recording"
            
            soundRecorder.record()
            sender.backgroundColor=UIColor.red
            sender.titleLabel?.textColor = UIColor.blue
            sender.setTitle("Stop", for: UIControlState())
        }
        else{
            _recordLabel.titleLabel?.text = "Recorded"
            soundRecorder.stop()
            sender.backgroundColor=UIColor.clear
//            sender.titleLabel?.textColor = UIColor.clear
            sender.setTitle("Record", for: UIControlState())
        }
    }
    
    
    
    func queryDatabase(){
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Joke", predicate:predicate)
        
        _publicData.perform(query, inZoneWith: nil,
                            completionHandler: ({results, error in
                                
                                if (error != nil) {
                                    DispatchQueue.main.async() {
                                        print("Cloud Error")
                                    }
                                } else {
                                    if results!.count > 0 {
                                        
                                        
                                        DispatchQueue.main.async() {
                                            
                                            for entry in results! {
                                                let cloudUPC = entry["content"] as? String
                                                    print("joke content from CloudKit \(String(describing: cloudUPC))")
                                                
                                                if let audio = entry["audio"] as? CKAsset
                                                {
                                                    do{
                                                    print("play audio")
                                                    self.soundPlayer = try AVAudioPlayer(contentsOf: audio.fileURL)
                                                    self.soundPlayer.delegate = self
                                                    self.soundPlayer.prepareToPlay()
                                                    self.soundPlayer.volume = 1.0
                                                    self.soundPlayer.play()
                                                    }catch{
                                                        
                                                        print("Error: soundPlayer error")
                        
                                                    }
                                                }
                                            }
                                        }
                                    }else {
                                        DispatchQueue.main.async() {
                                            print("no joke Found")
                                        }
                                    }
                                }
                            }))
    }
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
