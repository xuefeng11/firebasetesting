//
//  JokeDetailViewController.swift
//  Joke_of_Day
//
//  Created by Xuefeng Liu on 11/12/17.
//  Copyright © 2017 Xuefeng Liu. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import AVFoundation

class JokeDetailViewController: UIViewController,AVAudioPlayerDelegate{
    
    var _jokeTitleVal:String!
    var _jokeContentVal:String?
    var _recordId:CKRecordID!
    let _publicData = CKContainer.default().publicCloudDatabase
    
    
    @IBOutlet weak var _jokeTitle: UITextField!

    @IBOutlet weak var _jokeContent: UITextView!
    
    var _audio:CKAsset!
    var soundPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _jokeTitle.text = _jokeTitleVal
        _jokeContent.text = _jokeContentVal
    }
    @IBAction func _like(_ sender: UIButton) {
        
         self._publicData.fetch(withRecordID: _recordId){ [unowned self] record, error in
         if error != nil {
         
         print("error")
         
         } else {
         
            if let _record = record {
                
                _record["rate"] = NSNumber(value:(_record["rate"] as! NSNumber).intValue + 1)
                
                self._publicData.save(_record){(record,error) in
                    if let err = error{
                        print(err)
         }
         
                    guard record != nil else {
                        print("saved record with note")
                        return
                    }
         
                }
         
            }
            }
         }
    
    }
    
    @IBAction func _dislike(_ sender: UIButton) {
        
        self._publicData.fetch(withRecordID: _recordId){ [unowned self] record, error in
            if error != nil {
                
                print("error")
                
            } else {
                
                if let _record = record {
                    
                    _record["rate"] = NSNumber(value:(_record["rate"] as! NSNumber).intValue - 1)
                    
                    self._publicData.save(_record){(record,error) in
                        if let err = error{
                            print(err)
                        }
                        
                        guard record != nil else {
                            print("saved record with note")
                            return
                        }
                        
                    }
                    
                }
            }
        }

    }
    
    
    @IBAction func _playJokeAudio(_ sender: UIButton) {
        if let _audioTemp = _audio
        {
            do{
                print("play audio")
                self.soundPlayer = try AVAudioPlayer(contentsOf: _audioTemp.fileURL)
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
