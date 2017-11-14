//
//  JokeTableViewController.swift
//  Joke_of_Day
//
//  Created by Xuefeng Liu on 11/11/17.
//  Copyright © 2017 Xuefeng Liu. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class JokeTableViewController: UIViewController{
    
    @IBOutlet weak var _tableView: UITableView!
    var _jokeList:[Joke] = []
    let _publicData = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _tableView.delegate = self
        _tableView.dataSource = self
        queryDatabase()
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
                                                print(entry["title"]!)
                                                print(entry["content"]!)
                                                print(entry.recordID.recordName)
                                                let joke = Joke(jokeTitle: entry["title"] as! String, jokeContent: entry["content"] as? String, jokeAudio: (entry["audio"] as? CKAsset),recordId:entry.recordID)
                                                
                                                
                                                /*
                                                self._publicData.fetch(withRecordID: entry.recordID){ [unowned self] record, error in
                                                    if error != nil {
                                                    
                                                        print("error")
                                                    
                                                    } else {
                                                        
                                                        if let _record = record {
                                                            _record["title"]="jjjjjsssssss" as CKRecordValue
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
                                                    }*/
                                                
                                                self._jokeList.append(joke)
                                                self._tableView.reloadData()
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


extension JokeTableViewController: UITableViewDelegate,UITableViewDataSource {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "jokeDetailSegue" {
            if let data = sender as? Joke {
                let vc = segue.destination as! JokeDetailViewController
                vc._audio = data._jokeAudio
                vc._jokeContentVal = data._jokeContent
                vc._jokeTitleVal = data._jokeTitle
                vc._recordId = data._recordId
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _jokeList.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "jokeCell", for: indexPath) as! JokeTableViewControllerCell
        cell._jokeTitle.text = _jokeList[row]._jokeTitle
        return cell
    }
    
    //trigger segue when click on the group
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let joke = _jokeList[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: "jokeDetailSegue", sender: joke)
        
    }
    

}




