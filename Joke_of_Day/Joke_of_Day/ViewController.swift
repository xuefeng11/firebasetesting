//
//  ViewController.swift
//  Joke_of_Day
//
//  Created by Xuefeng Liu on 11/9/17.
//  Copyright © 2017 Xuefeng Liu. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var _jokeText: UITextView!
    let _publicData = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func _sendJoke(_ sender: UIButton) {
        
        let newJoke = CKRecord(recordType: "Joke")
        newJoke.setValue("hello", forKey: "content")
        
        _publicData.save(newJoke){(record,error) in
            if let err = error{
                print(err)
            }
            
            guard record != nil else {
                print("saved record with note")
                return
            }
        
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
}
