//
//  HistoryViewController.swift
//  lifecounter
//
//  Created by Nathanael Simon on 2/2/26.
//

import UIKit

class HistoryViewController: UIViewController {
    
    private let history: [HistoryEvent]
    private var tableView: UITableView!
    
    init(history: [HistoryEvent]) {
        self.history = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Game History"
        
        // Add close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTapped)
        )
        
        // Table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let event = history[indexPath.row]
        
        let absChange = abs(event.change)
        // Match requirement format: "Player 1 lost one life." "Player 3 lost four life."
        let changeWord = "life"  // Using "life" for both singular and plural as per requirement
        let direction = event.change > 0 ? "gained" : "lost"
        let numberWord: String
        switch absChange {
        case 1: numberWord = "one"
        case 2: numberWord = "two"
        case 3: numberWord = "three"
        case 4: numberWord = "four"
        case 5: numberWord = "five"
        default: numberWord = "\(absChange)"
        }
        
        cell.textLabel?.text = "Player \(event.playerNumber) \(direction) \(numberWord) \(changeWord)."
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    // No additional delegate methods needed
}

