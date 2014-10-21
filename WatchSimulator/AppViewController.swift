//
//  WatchAppViewController.swift
//  WatchSimulator
//
//  Created by temporary on 10/12/14.
//  Copyright (c) 2014 Ben Morrow. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var bpmLabel: UILabel!
    
    let shrinkSize = CGFloat(2.0 / 3)
    
    let smallSize = CGFloat(20)
    
    let switchToNewBeatDelay = 10.0
    
    var beatPaused = false
    
    var newBeatIcon: String? = nil
    
    let beatPatterns: [[AnyObject?]] = [
        ["❤️", "Mid-range", "Nominal", 80],
        ["💜", "Slow", "Nominal", 55],
        ["💙", "Sedated", "Nominal", 30],
        ["💚", "Erratic", "Erratic", nil],
        ["💛", "Fast", "Nominal", 180]]
    
    var currentBeatPattern = BeatPattern()
    
    var lastBeatPatternIndex = -1
    
    let iconLabel = UILabel()
    
    var rhythmStripImageView = UIImageView()
    
    var scrollView = UIScrollView()
    
    var beatTransitionTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        initAppearance()
        
        self.view.insertSubview(iconLabel, atIndex: 1)
        iconLabel.transform = CGAffineTransformMakeScale(shrinkSize, shrinkSize)
        
        newBeat()
        beat()
        timerToggle()
    }
    
    func initAppearance() -> Void {
        
        iconLabel.frame = self.view.bounds
        iconLabel.textAlignment = .Center
        iconLabel.font = UIFont.boldSystemFontOfSize(132)
        
        // Add the scroll view to our view.
        self.view.addSubview(scrollView)
        
        // Add the image view to the scroll view.
        scrollView.addSubview(rhythmStripImageView)
        
        // Set the translatesAutoresizingMaskIntoConstraints to NO so that the views autoresizing mask is not translated into auto layout constraints.
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        rhythmStripImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Set the constraints for the scroll view and the image view.
        let bindings = ["scrollView": scrollView, "imageView": rhythmStripImageView]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: nil, metrics: nil, views: bindings))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: bindings))
        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: bindings))
        scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: bindings))
        
        rhythmStripImageView.alpha = 0
        statusLabel.alpha = 0
        bpmLabel.alpha = 0
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewTapped");
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        scrollView.addGestureRecognizer(tapRecognizer);
        
    }
    
    func timerToggle(){
        
        if let timer = beatTransitionTimer {
            timer.invalidate()
            beatTransitionTimer = nil
        } else {
            beatTransitionTimer = NSTimer.scheduledTimerWithTimeInterval(switchToNewBeatDelay, target: self, selector: Selector("newBeat"), userInfo: nil, repeats: true)
        }
        
    }
    
    func scrollViewTapped() {
        beatPaused = !beatPaused
        timerToggle()
        if !beatPaused {
            UIView.animateWithDuration(0.2, delay: 0.0, options: .BeginFromCurrentState, animations: {
                self.iconLabel.transform = CGAffineTransformMakeScale(self.shrinkSize, self.shrinkSize)
                self.rhythmStripImageView.alpha = 0
                self.statusLabel.alpha = 0
                self.bpmLabel.alpha = 0
                }, completion: { _ in
                    self.beat()
                }
            )
        } else {
            
            var newContentOffsetX = (scrollView.contentSize.width - scrollView.frame.size.width) / 2;
            scrollView.contentOffset = CGPointMake(newContentOffsetX, 0)
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: .BeginFromCurrentState, animations: {
                
                let scale = CGAffineTransformMakeScale( self.smallSize / self.view.bounds.width, self.smallSize / self.view.bounds.width)
                let translation = CGAffineTransformMakeTranslation( self.view.bounds.width / -2 + self.smallSize / 2, self.view.bounds.height / -2 + self.smallSize / 2)
                self.iconLabel.transform = CGAffineTransformConcat(scale, translation)
                self.rhythmStripImageView.alpha = 1
                self.statusLabel.alpha = 1
                self.bpmLabel.alpha = 1
                }, completion: { _ in
                    
                    //begin slow scrolling scroll view
                    UIView.animateWithDuration(2.5, delay: 0.0, options: .AllowUserInteraction | .CurveLinear, animations: {
                        var bounds = self.scrollView.bounds;
                        bounds.origin.x += (self.scrollView.contentSize.width - self.scrollView.frame.size.width) / 3;
                        self.scrollView.bounds = bounds;
                        }, completion: { _ in
                        }
                    )

                }
            )
        }
    }
    
    func newBeat() {
        var randomBeatPatternIndex = lastBeatPatternIndex
        while (randomBeatPatternIndex == lastBeatPatternIndex) {
            randomBeatPatternIndex = Int(arc4random_uniform(UInt32(beatPatterns.count)))
        }
        lastBeatPatternIndex = randomBeatPatternIndex
        let beatValues = beatPatterns[randomBeatPatternIndex]
        currentBeatPattern = BeatPattern(icon: beatValues[0] as String, description: beatValues[1] as String, status: beatValues[2] as String, bpm: beatValues[3] as Int?)
        
        newBeatIcon = currentBeatPattern.icon
        
        rhythmStripImageView.image = currentBeatPattern.image
        
        statusLabel.text = currentBeatPattern.status
        
        if let bpm = currentBeatPattern.bpm {
            bpmLabel.text = "\(bpm)"
        } else {
            bpmLabel.text = ""
        }
        
        if !beatPaused {
            UIView.animateWithDuration(0.6, delay: 1.2, options: nil, animations: {
                self.bpmLabel.alpha = 1
                }, completion: { _ in
                    UIView.animateWithDuration(0.6, delay: 2.0, options: nil, animations: {
                        self.bpmLabel.alpha = 0
                        }, completion: { _ in
                        }
                    )
                }
            )
            
        }
        
    }
    
    func beat() {
        if !beatPaused {
            var duration = 0.0
            if let usableDuration = currentBeatPattern.duration {
                duration = usableDuration
            } else {
                duration = 1 / ( Double(arc4random_uniform(12)) + 1 )
            }
            UIView.animateWithDuration(duration / 2, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.iconLabel.transform = CGAffineTransformScale(self.iconLabel.transform, 1 / self.shrinkSize, 1 / self.shrinkSize)
                }, completion: { _ in
                    if !self.beatPaused {
                        UIView.animateWithDuration(duration / 2, delay: 0.0, options: .CurveEaseInOut, animations: {
                            self.iconLabel.transform = CGAffineTransformScale(self.iconLabel.transform, self.shrinkSize, self.shrinkSize)
                            
                            }, completion: { _ in
                                if let icon = self.newBeatIcon {
                                    self.iconLabel.text = self.newBeatIcon
                                    self.newBeatIcon = nil
                                }
                                self.beat()
                            })
                    }
            })
        }
        
    }

}
