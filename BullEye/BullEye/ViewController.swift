//
//  ViewController.swift
//  BullEye
//
//  Created by yuan cheng on 28/6/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    
    var currentValue:Int = 50
    var targetValue:Int = 0
    var totalScore = 0
    var round = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startNewGame()
        
        //设置滑动条的外观
        
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")!
        slider.setThumbImage(thumbImageNormal, for:  .normal)
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")!
        slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        let trackLeftImage = UIImage(named: "SliderTrackLeft")!
        let trackLeftResizable = trackLeftImage.resizableImage(withCapInsets: insets)
        
        slider.setMinimumTrackImage(trackLeftResizable, for: .normal)
        
        let trackRightImage = UIImage(named: "SliderTrackRight")!
        let trackRightResizable = trackRightImage.resizableImage(withCapInsets: insets)
        slider.setMaximumTrackImage(trackRightResizable, for: .normal)

    }

    @IBAction func showAlert(){
        let score:Int = 100 - abs(currentValue - targetValue)
        totalScore += score
        
        //设置标题的内容
        let title: String
        if score == 100{
            title = "运气逆天！赶紧去买注彩票吧！"
        }else if score > 95 {
            title = "太棒了！差一点就到了！"
        }else if score > 90 {
            title = "很不错！继续努力！"
        }else {
            title = "差太远了，君在长江头，我在长江尾~"
        }
        
        let message = "slider current value: \(currentValue)\n" + "target value: \(targetValue)\n" + "score is: \(score)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "learn swift in 2019", style: .default, handler: { _ in self.startNewRound()})
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func sliderMoved(slider:UISlider){
        // print("slider current value: \(slider.value)")
        currentValue = lroundf(slider.value)
    }
    
    @IBAction func startOver(){
        startNewGame()
    }
    
    func startNewRound(){
        currentValue = Int.random(in: 0...100)
        targetValue = Int.random(in: 0...100)
        slider.value = Float(currentValue)
        round += 1
        updateLabels()
    }
    
    func startNewGame(){
        totalScore = 0
        round = 0
        startNewRound()
        
        // the fade out/fade in animation effect
        let transition = CATransition()
        transition.type = CATransitionType.fade
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeOut)
        view.layer.add(transition, forKey: nil)
    }
    
    func updateLabels(){
        targetLabel.text = String(targetValue)
        scoreLabel.text = String(totalScore)
        roundLabel.text = String(round)
    }
}

