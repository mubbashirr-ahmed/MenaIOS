//
//  TabBarController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    var upperLineView: UIView!
    let spacing: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
               self.addTabbarIndicatorView(index: 0, isFirstTime: true)
           }
        for viewController in viewControllers ?? [] {
                    viewController.tabBarItem.title = ""
                }
        
        // Do any additional setup after loading the view.
        self.delegate = self
        
    }
    
    ///Add tabbar item indicator uper line
      func addTabbarIndicatorView(index: Int, isFirstTime: Bool = false){
          guard let tabView = tabBar.items?[index].value(forKey: "view") as? UIView else {
              return
          }
//          if !isFirstTime{
//              upperLineView.removeFromSuperview()
//          }
//          upperLineView = UIView(frame: CGRect(x: tabView.frame.minX + spacing, y: tabView.frame.minY + 0.1, width: tabView.frame.size.width - spacing * 2, height: 4))
//          upperLineView.backgroundColor = UIColor.secondary
//          tabBar.addSubview(upperLineView)
      }
    
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
           // Check if the selected view controller is the first one
           if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 0 {
               // Remove shadow and corner radius for the first view controller's tab bar
//               customizeTabBar(tabBarController.tabBar)
           } else {
               // Reset to default appearance for other view controllers
//               resetTabBarAppearance(tabBarController.tabBar)
           }
       }

       func customizeTabBar(_ tabBar: UITabBar) {
           // Remove shadow
           tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
           tabBar.layer.shadowRadius = 0
           tabBar.layer.shadowColor = UIColor.clear.cgColor
           tabBar.layer.shadowOpacity = 0

           // Remove corner radius
           tabBar.layer.cornerRadius = 0
           tabBar.layer.maskedCorners = []
       }

       func resetTabBarAppearance(_ tabBar: UITabBar) {
           // Reset shadow and corner radius to default values
           tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
           tabBar.layer.shadowRadius = 10
           tabBar.layer.shadowColor = UIColor.black.cgColor
           tabBar.layer.shadowOpacity = 0.1

           tabBar.layer.cornerRadius = 30
           tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       }
    
}

