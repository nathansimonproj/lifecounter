//
//  ViewController.swift
//  lifecounter
//
//  Created by Nathanael Simon on 1/29/26.
//

import UIKit

struct HistoryEvent {
    let playerNumber: Int
    let change: Int
    let timestamp: Date
}

class ViewController: UIViewController {

    // MARK: - Properties
    private var players: [PlayerView] = []
    private var gameHistory: [HistoryEvent] = []
    private var gameStarted: Bool = false
    private let minPlayers = 2
    private let maxPlayers = 8
    private let initialPlayerCount = 2
    
    // MARK: - UI Elements
    private var playersStackView: UIStackView!
    private var addPlayerButton: UIButton!
    private var historyButton: UIButton!
    private var loserLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Clear any storyboard views
        view.subviews.forEach { $0.removeFromSuperview() }
        setupUI()
        initializePlayers()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Top buttons stack
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.distribution = .fillEqually
        topStackView.spacing = 16
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topStackView)
        
        // Add Player button
        addPlayerButton = UIButton(type: .system)
        addPlayerButton.setTitle("Add Player", for: .normal)
        addPlayerButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addPlayerButton.addTarget(self, action: #selector(addPlayerTapped), for: .touchUpInside)
        topStackView.addArrangedSubview(addPlayerButton)
        
        // History button
        historyButton = UIButton(type: .system)
        historyButton.setTitle("History", for: .normal)
        historyButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        historyButton.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        topStackView.addArrangedSubview(historyButton)
        
        // Players stack view
        playersStackView = UIStackView()
        playersStackView.axis = .vertical
        playersStackView.spacing = 8
        playersStackView.distribution = .fillEqually
        playersStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playersStackView)
        
        // Loser label
        loserLabel = UILabel()
        loserLabel.textAlignment = .center
        loserLabel.font = .boldSystemFont(ofSize: 20)
        loserLabel.textColor = .systemRed
        loserLabel.numberOfLines = 0
        loserLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loserLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            topStackView.heightAnchor.constraint(equalToConstant: 40),
            
            playersStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 12),
            playersStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            playersStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            playersStackView.bottomAnchor.constraint(equalTo: loserLabel.topAnchor, constant: -12),
            
            loserLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loserLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loserLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            loserLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func initializePlayers() {
        for i in 1...initialPlayerCount {
            addPlayerView(playerNumber: i)
        }
        updateLoserLabel()
    }
    
    private func addPlayerView(playerNumber: Int) {
        let playerView = PlayerView(playerNumber: playerNumber)
        playerView.delegate = self
        players.append(playerView)
        playersStackView.addArrangedSubview(playerView)
    }
    
    // MARK: - Actions
    @objc private func addPlayerTapped() {
        guard players.count < maxPlayers else { return }
        let newPlayerNumber = players.count + 1
        addPlayerView(playerNumber: newPlayerNumber)
        updateAddPlayerButtonState()
    }
    
    @objc private func showHistory() {
        let historyVC = HistoryViewController(history: gameHistory)
        let navController = UINavigationController(rootViewController: historyVC)
        present(navController, animated: true)
    }
    
    private func updateAddPlayerButtonState() {
        addPlayerButton.isEnabled = !gameStarted && players.count < maxPlayers
    }
    
    private func updateLoserLabel() {
        var losers: [Int] = []
        for (index, player) in players.enumerated() {
            if player.currentLife <= 0 {
                losers.append(index + 1)
            }
        }
        
        if losers.isEmpty {
            loserLabel.text = ""
        } else if losers.count == 1 {
            loserLabel.text = "Player \(losers[0]) LOSES!"
        } else {
            let losersText = losers.map { "Player \($0)" }.joined(separator: ", ")
            loserLabel.text = "\(losersText) LOSE!"
        }
    }
}

// MARK: - PlayerViewDelegate
extension ViewController: PlayerViewDelegate {
    func playerLifeDidChange(playerNumber: Int, oldLife: Int, newLife: Int) {
        let change = newLife - oldLife
        let event = HistoryEvent(playerNumber: playerNumber, change: change, timestamp: Date())
        gameHistory.append(event)
        
        // Mark game as started if life changed (any change means game started)
        if !gameStarted && change != 0 {
            gameStarted = true
            updateAddPlayerButtonState()
        }
        
        // Check if game is over (all players at 0 or below) - enable add player again
        let allPlayersDead = players.allSatisfy { $0.currentLife <= 0 }
        if allPlayersDead && gameStarted {
            gameStarted = false
            updateAddPlayerButtonState()
        }
        
        updateLoserLabel()
    }
}

// MARK: - PlayerView
protocol PlayerViewDelegate: AnyObject {
    func playerLifeDidChange(playerNumber: Int, oldLife: Int, newLife: Int)
}

class PlayerView: UIView {
    weak var delegate: PlayerViewDelegate?
    
    private let playerNumber: Int
    private(set) var currentLife: Int = 20 {
        didSet {
            updateLifeLabel()
            delegate?.playerLifeDidChange(playerNumber: playerNumber, oldLife: oldValue, newLife: currentLife)
        }
    }
    
    private let nameLabel: UILabel
    private let lifeLabel: UILabel
    private let plusButton: UIButton
    private let minusButton: UIButton
    private let valueTextField: UITextField
    private let applyPlusButton: UIButton
    private let applyMinusButton: UIButton
    
    init(playerNumber: Int) {
        self.playerNumber = playerNumber
        
        // Name label
        nameLabel = UILabel()
        nameLabel.text = "Player \(playerNumber)"
        nameLabel.textAlignment = .center
        nameLabel.font = .boldSystemFont(ofSize: 16)
        
        // Life label
        lifeLabel = UILabel()
        lifeLabel.text = "20"
        lifeLabel.textAlignment = .center
        lifeLabel.font = .boldSystemFont(ofSize: 32)
        
        // Plus button
        plusButton = UIButton(type: .system)
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        // Minus button
        minusButton = UIButton(type: .system)
        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        
        // Value text field
        valueTextField = UITextField()
        valueTextField.placeholder = "Amount"
        valueTextField.keyboardType = .numberPad
        valueTextField.borderStyle = .roundedRect
        valueTextField.textAlignment = .center
        
        // Apply buttons (for custom amount)
        applyPlusButton = UIButton(type: .system)
        applyPlusButton.setTitle("+", for: .normal)
        applyPlusButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        
        applyMinusButton = UIButton(type: .system)
        applyMinusButton.setTitle("-", for: .normal)
        applyMinusButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        
        super.init(frame: .zero)
        
        // Set delegate after super.init
        valueTextField.delegate = self
        
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        // Stack for buttons
        let buttonStack = UIStackView(arrangedSubviews: [plusButton, minusButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 6
        
        // Stack for value input
        let inputButtonStack = UIStackView(arrangedSubviews: [applyPlusButton, applyMinusButton])
        inputButtonStack.axis = .horizontal
        inputButtonStack.distribution = .fillEqually
        inputButtonStack.spacing = 6
        
        let inputStack = UIStackView(arrangedSubviews: [valueTextField, inputButtonStack])
        inputStack.axis = .horizontal
        inputStack.distribution = .fill
        inputStack.spacing = 6
        
        // Main vertical stack
        let mainStack = UIStackView(arrangedSubviews: [nameLabel, lifeLabel, buttonStack, inputStack])
        mainStack.axis = .vertical
        mainStack.spacing = 4
        mainStack.distribution = .fillEqually
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            valueTextField.widthAnchor.constraint(equalTo: inputStack.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupActions() {
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        applyPlusButton.addTarget(self, action: #selector(applyPlusTapped), for: .touchUpInside)
        applyMinusButton.addTarget(self, action: #selector(applyMinusTapped), for: .touchUpInside)
    }
    
    @objc private func plusTapped() {
        currentLife += 1
    }
    
    @objc private func minusTapped() {
        currentLife -= 1
    }
    
    @objc private func applyPlusTapped() {
        applyValue(isPositive: true)
    }
    
    @objc private func applyMinusTapped() {
        applyValue(isPositive: false)
    }
    
    private func applyValue(isPositive: Bool) {
        guard let text = valueTextField.text,
              !text.isEmpty,
              let value = Int(text),
              value > 0 else {
            valueTextField.text = ""
            valueTextField.resignFirstResponder()
            return
        }
        
        currentLife += isPositive ? value : -value
        valueTextField.text = ""
        valueTextField.resignFirstResponder()
    }
    
    private func updateLifeLabel() {
        lifeLabel.text = "\(currentLife)"
        if currentLife <= 0 {
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
            lifeLabel.textColor = .systemRed
        } else {
            backgroundColor = .systemBackground
            lifeLabel.textColor = .label
        }
    }
}

// MARK: - UITextFieldDelegate
extension PlayerView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow numeric input
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
