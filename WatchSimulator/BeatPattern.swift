//
//  BeatPattern.swift
//  WatchSimulator
//
//  Created by temporary on 10/18/14.
//  Copyright (c) 2014 Ben Morrow. All rights reserved.
//

import UIKit

struct BeatPattern {
    var icon = "❤️"
    var description = "Mid-range"
    var status = "Nominal"
    var bpm: Int?
    var duration: Double? {
        get {
            if let intBpm = bpm {
               return 60.0 / Double(intBpm)
            } else {
                return nil
            }
        }
    }
    var image: UIImage {
        get {
            if let image = UIImage(named: (description + ".png").lowercaseString) {
                return image
            } else {
                return UIImage()
            }
        }
    }
    init(){
        
    }
    init(icon: String, description: String, status: String, bpm: Int?){
        self.icon = icon
        self.description = description
        self.status = status
        self.bpm = bpm
    }
}