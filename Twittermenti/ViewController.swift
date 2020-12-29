//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    var tweetCount = 100
    let sentimentClassifier = TweetSentimentClassifier()
    let swifter = Swifter(consumerKey: "lAtSmVLW8QoBXYlZFKYyH7nKH", consumerSecret: "7CU74mq9nnmpWvK1cJn0I2xMOcfulCPEjkMLMWtZWaak9aAiXT")
    //Bearer token: AAAAAAAAAAAAAAAAAAAAAM6rKwEAAAAAAYER2PhjV98gy%2BUkJDQcxKKWw9k%3Dje8Zf4G3UPrPXyEEqRCJfgTEOQw8WEeVi1MlSlCZKDi8ynwV6L
    override func viewDidLoad() {
        super.viewDidLoad()
        let prediction = try! sentimentClassifier.prediction(text: "@Apple, I like it!")
        print(prediction.label)
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    func fetchTweets(){
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0 ..< self.tweetCount {
                    if let tweet = results[i]["full_text"].string{
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.predictTweet(tweets)
            }) { (error) in
                print(error)
            }
        }
    }
    func predictTweet(_ tweets: [TweetSentimentClassifierInput]){
        do{
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for pre in predictions{
                let sentiment = pre.label
                if sentiment=="Pos"{
                    sentimentScore+=1
                }else if sentiment=="Neg"{
                    sentimentScore-=1
                }
            }
            
            updateUI(sentimentScore: sentimentScore)
        }catch{
            print("There is an error\(error)")
        }
    }
    func updateUI(sentimentScore: Int){
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
}

