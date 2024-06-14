//
//  SettingViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
  //MARK: - @IBOutlet

  @IBOutlet weak var tableView: UITableView!
  //MARK: - Local variables
 let appearanceSwitch = UISwitch()
  var dataSource = [
    "Change Password",
    "Enable Face ID",
    "Dark Mode",
    "View Private Key",
    "View Seed Words",
    "Delete Wallet",
    "Change Bank Details",
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.delegate = self
    self.tableView.dataSource = self
      setupNotificationObserver()
    // Do any additional setup after loading the view.
  }

}

extension SettingViewController{
    // MARK: - Logout

    private func logout() {

      let alert = UIAlertController(
        title: Constants.string.areYouSure.localize(), message: Constants.string.deletingWalletMayResult.localize(),
        preferredStyle: .actionSheet)
      let logoutAction = UIAlertAction(title: Constants.string.deleteWallet.localize(), style: .destructive)
      { (_) in
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
      }

      let cancelAction = UIAlertAction(
        title: Constants.string.Cancel.localize(), style: .cancel, handler: nil)

      alert.view.tintColor = .primary
      alert.addAction(logoutAction)
      alert.addAction(cancelAction)

      self.present(alert, animated: true, completion: nil)
    }
    
    func setupAppearanceSwitch() {
            appearanceSwitch.addTarget(self, action: #selector(toggleAppearance), for: .valueChanged)
            appearanceSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    func setupNotificationObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleAppearanceSwitchToggle(_:)), name: .appearanceSwitchToggled, object: nil)
        }
    @objc func handleAppearanceSwitchToggle(_ notification: Notification) {
            guard let isOn = notification.object as? Bool else { return }
            setAppearance(darkMode: isOn)
        }
    @objc func toggleAppearance(_ sender: UISwitch) {
           if sender.isOn {
               setAppearance(darkMode: true)
           } else {
               setAppearance(darkMode: false)
           }
       }

       func setAppearance(darkMode: Bool) {
           UserDefaults.standard.set(darkMode, forKey: "isDarkMode")
           UIApplication.shared.windows.forEach { window in
               window.overrideUserInterfaceStyle = darkMode ? .dark : .light
           }
       }
}
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 7
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell {
      cell.lblTitle.text = self.dataSource[indexPath.row]
        if indexPath.row == 2{
            cell.appearanceSwitch.isHidden = false
        }
        else{
            cell.appearanceSwitch.isHidden = true
        }
      return cell
    }
    return UITableViewCell()
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row{
        case 0:
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ChangePasswordViewController) as? ChangePasswordViewController{
                vc.modalPresentationStyle = .fullScreen
                vc.customTitle = Constants.string.changePassword.localize()
                self.present(vc, animated: true, completion: nil)
            }
            break
        case 1:
            self.push(id: Storyboard.Ids.ChangePasswordViewController, animation: true)
            break
        case 2:
            self.push(id: Storyboard.Ids.ChangePasswordViewController, animation: true)
            break
        case 3:
           
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ShowPrivateKeyViewController) as? ShowPrivateKeyViewController{
                vc.modalPresentationStyle = .fullScreen
                vc.customTitle = Constants.string.privateKey.localize()
                self.present(vc, animated: true, completion: nil)
            }
            break
        case 4:
            self.push(id: Storyboard.Ids.ChangePasswordViewController, animation: true)
        case 5:
           //Delete wallet
            logout()
            break
        case 6:
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ChangeBankingDetailViewController) as? ChangeBankingDetailViewController{
                vc.modalPresentationStyle = .fullScreen
                vc.customTitle = Constants.string.updateBankDetail.localize()
                self.present(vc, animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }
    
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }
    

}

class SettingCell: UITableViewCell {

  @IBOutlet weak var viewBg: UIView!

  @IBOutlet weak var lblTitle: UILabel!

    @IBOutlet weak var appearanceSwitch: UISwitch!
    
  override func awakeFromNib() {
    viewBg.layer.cornerRadius = 15
      appearanceSwitch.translatesAutoresizingMaskIntoConstraints = false
    appearanceSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
  }

    @objc func switchToggled() {
            NotificationCenter.default.post(name: .appearanceSwitchToggled, object: appearanceSwitch.isOn)
        }
}
