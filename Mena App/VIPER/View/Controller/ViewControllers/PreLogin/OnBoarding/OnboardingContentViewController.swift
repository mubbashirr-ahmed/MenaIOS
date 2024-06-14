//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//
import UIKit

class OnboardingContentViewController: UIViewController {

  //MARK: - @IBOutlet
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgStepper: UIImageView!
  @IBOutlet weak var lblTitle: UILabel! {
    didSet {
      lblTitle.numberOfLines = 0
    }
  }
  @IBOutlet weak var lblSubTitle: UILabel! {
    didSet {
      lblSubTitle.numberOfLines = 0
    }
  }

  //MARK: - localVariables
  var index = 0
  var heading = ""
  var subHeading = ""
  var image = UIImage()
  var bgColor = UIColor()
  var stepper = UIImage()

  //MARK: - viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    initalLoads()
  }

}
//MARK: - extension
extension OnboardingContentViewController {
  func initalLoads() {
    setupTextLabel()
    setFont()
    imgView.image = image
    imgStepper.image = stepper
    
  }

  func setupTextLabel() {
    self.lblTitle.text = heading
    self.lblSubTitle.text = subHeading

  }

  func setFont() {
//    Common.setFont(to: lblTitle!, isTitle: true, size: 20)
//    Common.setFont(to: lblSubTitle!, size: 14, textAlingment: .center, font: .Regular)
  }
}
