//
//  CustomHeader.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import UIKit

class CustomHeaderView: UIView {

    let backButton: UIButton
    let titleLabel: UILabel

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override init(frame: CGRect) {
        backButton = UIButton(type: .system)
        titleLabel = UILabel()

        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // Setup backButton
        if let image = UIImage(systemName: "arrow.left") {
            backButton.setImage(image, for: .normal)
            backButton.tintColor = UserDefaults.standard.bool(forKey: "isDarkMode") ? .white : .black
        }
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)

        // Setup titleLabel
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Add constraints
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
