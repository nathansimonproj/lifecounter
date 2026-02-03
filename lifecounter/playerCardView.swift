//
//  playerCardView.swift
//  lifecounter
//
//  Created by Nathanael Simon on 2/2/26.
//

import UIKit

protocol PlayerCardDelegate: AnyObject {
    func playerHealthDidChange(playerNumber: Int, oldHealth: Int, newHealth: Int)
}

class playerCardView : UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerHealthLabel: UILabel!
    @IBOutlet weak var applyVal: UITextField!
    
    var playerNumber: Int = 1
    weak var delegate: PlayerCardDelegate?

    
    // MARK: - Properties
    var playerName = "Player"
    var playerHealth = 20 {
        didSet {
            let oldValue = oldValue
            updateLabel()
            delegate?.playerHealthDidChange(playerNumber: playerNumber, oldHealth: oldValue, newHealth: playerHealth)
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
    
    // MARK: - Load XIB
    private func loadFromNib() {
        // Load the XIB file
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "playerCardView", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        
        // Add contentView to self
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Setup initial state
        setupUI()
    }
    
    private func setupUI() {
        // Set initial values
        updateLabel()
        
        // Configure text field
        applyVal.keyboardType = .numberPad
        applyVal.placeholder = "valToAdd"
        
        // Add corner radius and shadow
        contentView.layer.cornerRadius = 40
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 0.1
    }
    
    // MARK: - Update Methods
    func updateName(playerNum: Int) {
        playerNameLabel.text = playerName + " " + String(playerNum)
    }
    
    func updateLabel() {
        playerHealthLabel.text = "\(playerHealth)"
        if playerHealth <= 0 {
            // Player lost - change background color to indicate
            contentView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            playerHealthLabel.textColor = .red
        } else {
            contentView.backgroundColor = .white
            playerHealthLabel.textColor = .black
        }
    }
    
    // MARK: - Actions
    @IBAction func apply() {
        guard let text = applyVal.text,
              let value = Int(text) else {
            // If text is empty or not a number, do nothing
            return
        }
        
        playerHealth += value
        applyVal.text = ""  // Clear the text field after applying
        
        // Dismiss keyboard
        applyVal.resignFirstResponder()
    }
    
    // MARK: - Public Configuration
    func configure(playerNum: Int, initialHealth: Int = 20) {
        self.playerNumber = playerNum
        self.playerHealth = initialHealth
        updateName(playerNum: playerNum)
    }
    
    // Reset player to starting health
    func reset(toHealth health: Int = 20) {
        playerHealth = health
        applyVal.text = ""
    }
}
