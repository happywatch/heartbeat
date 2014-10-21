// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"



struct Celsius {
    var temperatureInCelsius: Double = 0.0
    
    init(fromFahrenheit fahrenheit: Double) {
        temperatureInCelsius = (fahrenheit - 32.0) / 1.8
    }
    
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }
}

let boilingPointOfWater = Celsius(fromFahrenheit: 212.0)
// boilingPointOfWater.temperatureInCelsius is 100.0

let freezingPointOfWater = Celsius(fromKelvin: 273.15)
// freezingPointOfWater.temperatureInCelsius is 0.0


let superView = UIView()
superView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
/*
let view = UIView()
view.backgroundColor = UIColor.redColor()
view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
superView.addSubview(view)

view.transform = CGAffineTransformScale(view.transform, 0.25, 0.25)
view.transform = CGAffineTransformRotate(view.transform, 1);
superView
//view.transform = CGAffineTransformScale(view.transform, 4, 4)
*/
let iconLabel = UILabel()
iconLabel.frame = superView.bounds
iconLabel.textAlignment = .Center
iconLabel.font = UIFont.boldSystemFontOfSize(45)
iconLabel.text = "❤️"
superView.addSubview(iconLabel)
superView
iconLabel.transform = CGAffineTransformScale(iconLabel.transform, 0.25, 0.25)
superView
iconLabel.transform = CGAffineTransformIdentity
superView
iconLabel.transform = CGAffineTransformScale(iconLabel.transform, 4, 4)
superView
iconLabel.transform = CGAffineTransformScale(iconLabel.transform, 4, 4)
superView
iconLabel.transform = CGAffineTransformIdentity
superView




struct BeatPattern {
    var icon = "❤️"
    var description = "Normal"
    var bpm = 80
    var duration: Double {
        get {
            return 60.0 / Double(bpm)
        }
        set(duration) {
            bpm = Int(60.0 / duration as Double)
        }
    }
    init(icon: String, description: String, bpm: Int){
        self.icon = icon
        self.description = description
        self.bpm = bpm
    }
    
    
}


let beatPatterns = [
    ["❤️", "Normal", 80],
    ["💜", "Sedated", 55],
    ["💙", "Slow", 30],
    ["💚", "Erratic", -1],
    ["💛", "Fast", 180]]

let randomBeatPatternIndex = Int(arc4random_uniform(UInt32(beatPatterns.count)))
let beatValues = beatPatterns[randomBeatPatternIndex]
let currentBeatPattern = BeatPattern(icon: beatValues[0] as String, description: beatValues[1] as String, bpm: beatValues[2] as Int)

print(currentBeatPattern.icon)



