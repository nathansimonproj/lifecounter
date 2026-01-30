//
//  ViewController.swift
//  lifecounter
//
//  Created by Nathanael Simon on 1/29/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var player1LifeLabel: UILabel!
    @IBOutlet weak var player2LifeLabel: UILabel!
    @IBOutlet weak var loserLabel: UILabel!

    var player1Life = 20
    var player2Life = 20
    
    func updateLabels() {
        
        player1LifeLabel.text = "\(player1Life)"
        player2LifeLabel.text = "\(player2Life)"
        
        if player1Life <= 0 {
            loserLabel.text = "Player 1 LOSES!"
        }
        else if player2Life <= 0 {
            loserLabel.text = "Player 2 LOSES!"
        }
        else {
            loserLabel.text = ""
        }
    }
    
    @IBAction func p1Plus(_ sender: UIButton) {
        player1Life += 1
        updateLabels()
    }
    
    @IBAction func p1Minus(_ sender: UIButton) {
        player1Life -= 1
        updateLabels()
    }
    
    @IBAction func p1PlusFive(_ sender: UIButton) {
        player1Life += 5
        updateLabels()
    }
    
    @IBAction func p1MinusFive(_ sender: UIButton) {
        player1Life -= 5
        updateLabels()
    }
    
    @IBAction func p2Plus(_ sender: UIButton) {
        player2Life += 1
        updateLabels()
    }
    
    @IBAction func p2Minus(_ sender: UIButton) {
        player2Life -= 1
        updateLabels()
    }
    
    @IBAction func p2PlusFive(_ sender: UIButton) {
        player2Life += 5
        updateLabels()
    }
    
    @IBAction func p2MinusFive(_ sender: UIButton) {
        player2Life -= 5
        updateLabels()
    }
    
    
    
}

