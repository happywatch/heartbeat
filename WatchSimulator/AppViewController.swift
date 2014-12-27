//
//  WatchAppViewController.swift
//  WatchSimulator
//
//  Copyright (c) 2014 Ben Morrow. All rights reserved.
//
//  Developed by: HappyWatch
//  http://happy.watch
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal with the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimers.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimers in the documentation and/or other materials provided with the distribution.
//  Neither the names of HappyWatch, nor the names of its contributors may be used to endorse or promote products derived from this Software without specific prior written permission.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH THE SOFTWARE.

import UIKit

class AppViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var bpmLabel: UILabel!
    
    let shrinkFactor = CGFloat(2.0 / 3) // when the heart is beating, this is the size it shrinks to
  
    var expandFactor: CGFloat {
      return 1.0 / shrinkFactor // when the heart is beating, the size it expands to is the inverse of the shrinkFactor
    }
  
    let smallSize = CGFloat(20) // when you tap the heart and it shrinks down to fit in the title bar. This is the size it shrinks to.
  
    let switchToNewBeatDelay = 10.0 // number of seconds before simulating a new beat
    
    var beatPaused = false
    
    var newBeatIcon: String? = nil
    
    let beatPatterns = [
        BeatPattern(icon: "❤️", description: "Mid-range", status: "Nominal", bpm: 80),
        BeatPattern(icon: "💜", description: "Slow", status: "Nominal", bpm: 55),
        BeatPattern(icon: "💙", description: "Sedated", status: "Nominal", bpm: 30),
        BeatPattern(icon: "💚", description: "Erratic", status: "Erratic", bpm: nil),
        BeatPattern(icon: "💛", description: "Fast", status: "Nominal", bpm: 180)]
    
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
        iconLabel.transform = CGAffineTransformMakeScale(shrinkFactor, shrinkFactor)
        
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
                self.iconLabel.transform = CGAffineTransformMakeScale(self.shrinkFactor, self.shrinkFactor)
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
        currentBeatPattern = beatPatterns[randomBeatPatternIndex]
        
        newBeatIcon = currentBeatPattern.icon
        
        if let image = currentBeatPattern.image {
            rhythmStripImageView.image = currentBeatPattern.image
        }
        
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
                duration = usableDuration // if the duration exists, we use it
            } else {
                duration = 1 / ( Double(arc4random_uniform(12)) + 1 ) // otherwise we generate a random one just this once
            }
            UIView.animateWithDuration(duration / 2, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.iconLabel.transform = CGAffineTransformScale(self.iconLabel.transform, self.expandFactor, self.expandFactor)
                }, completion: { _ in
                    if !self.beatPaused {
                        UIView.animateWithDuration(duration / 2, delay: 0.0, options: .CurveEaseInOut, animations: {
                            self.iconLabel.transform = CGAffineTransformScale(self.iconLabel.transform, self.shrinkFactor, self.shrinkFactor)
                            
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
