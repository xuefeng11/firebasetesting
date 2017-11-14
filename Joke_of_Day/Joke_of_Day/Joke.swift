//
//  Joke.swift
//  Joke_of_Day
//
//  Created by Xuefeng Liu on 11/11/17.
//  Copyright © 2017 Xuefeng Liu. All rights reserved.
//

import Foundation
import CloudKit
class Joke {
    var _jokeTitle:String
    var _jokeContent:String?
    var _jokeAudio:CKAsset?
    var _recordId: CKRecordID
    init(jokeTitle:String,jokeContent:String?,jokeAudio:CKAsset?,recordId:CKRecordID){
        self._jokeTitle = jokeTitle
        self._jokeContent = jokeContent
        self._jokeAudio = jokeAudio
        self._recordId = recordId
    }
    
}
