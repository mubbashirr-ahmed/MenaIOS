//
//  Identifiers.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

// MARK:- Storyboard Id
struct Storyboard {
    
    static let Ids = Storyboard()
    let LaunchViewController = "OnboardingViewController"
    let PasswordViewController = "PasswordViewController"
    let CreateWalletViewController = "CreateWalletViewController"
    let LaunchNavigationController = "LaunchNavigationController"
    let tabBarController = "TabBarController"
    let HomeViewController = "HomeViewController"
    let PaymentViewController = "PaymentViewController"
    let SettingViewController = "SettingViewController"
    let TransactionHistoryViewController = "TransactionHistoryViewController"
    let ChangePasswordViewController = "ChangePasswordViewController"
    let ChangeBankingDetailViewController = "ChangeBankingDetailViewController"
    let PrivateKeyViewController = "PrivateKeyViewController"
    let ImportWalletViewController = "ImportWalletViewController"
    let ImportPrivateKeyViewController = "ImportPrivateKeyViewController"
    let RefillViewController = "RefillViewController"
    let SendCoinViewController = "SendCoinViewController"
    let RecieveViewController = "RecieveViewController"
    let WaitingNFCViewController = "WaitingNFCViewController"
    let ImportMnemonicViewController = "ImportMnemonicViewController"
    let ShowPrivateKeyViewController = "ShowPrivateKeyViewController"
    let AllRefillViewController = "AllRefillViewController"
    
}


//MARK:- XIB Cell Names
struct XIB {
    
    static let Names = XIB()
    let TransactionCell = "TransactionCell"
    
}


//MARK:- Notification
extension Notification.Name {
    static let appearanceSwitchToggled = Notification.Name("appearanceSwitchToggled")
}

