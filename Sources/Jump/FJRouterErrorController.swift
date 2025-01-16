//
//  FJRouterErrorController.swift
//  FJRouter
//
//  Created by zgjff on 2024/11/21.
//

import UIKit

final class FJRouterErrorController: UIViewController {
    init(state: FJRouterState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let state: FJRouterState
}

extension FJRouterErrorController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

private extension FJRouterErrorController {
    func setup() {
        view.backgroundColor = .systemBackground
        title = "404"
        
        let backButton = UIButton()
        backButton.setAttributedTitle(NSAttributedString(string: "Go Back"), for: [])
        backButton.backgroundColor = .orange
        backButton.addTarget(self, action: #selector(onTap), for: .primaryActionTriggered)
        backButton.layer.cornerRadius = 25
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -150),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])
        
        let errorInfo: String
        if let error = state.error {
            if case .empty = error {
                errorInfo = "no routes for url: \(state.url)"
            } else {
                errorInfo = String(describing: error)
            }
        } else {
            errorInfo = "no routes for url: \(state.url)"
        }
        let infoLabel = UILabel()
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.text = errorInfo
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = .red
        view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -36),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoLabel.bottomAnchor.constraint(lessThanOrEqualTo: backButton.topAnchor, constant: -30)
        ])
    }
    
    @IBAction func onTap() {
        guard let navi = navigationController else {
            dismiss(animated: true)
            return
        }
        let idx = navi.viewControllers.lastIndex(of: self)
        guard let idx, idx > 0 else {
            dismiss(animated: true)
            return
        }
        navi.popViewController(animated: true)
    }
}
