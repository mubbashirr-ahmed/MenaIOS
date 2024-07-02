//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//
import UIKit

class OnboardingViewController: UIViewController {

  //MARK: - @IBOutlets

  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var btnSkip: UIButton!
  @IBOutlet weak var btnBack: UIButton!
  @IBOutlet weak var btnGetStarted: UIButton!
  @IBOutlet weak var btnForward: UIButton!

  //MARK: - Local Variables
  weak var onBoardingPageViewController: OnboardingPageViewController?
  var presenter: PostPresenterInputProtocol?

  //MARK: -viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()

    initialLoads()

  }
  //MARK: -viewWillAppear
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = true

  }
  //MARK: -prepare
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let onBoardingViewController = segue.destination as? OnboardingPageViewController {
      onBoardingViewController.pageViewControllerDelagate = self
      onBoardingPageViewController = onBoardingViewController
    }
  }

  @IBAction func skipButtonTapped(_ sender: Any) {
      
      if WalletManager.shared.doesKeystoreExist(){
          self.push(id: Storyboard.Ids.PasswordViewController, animation: true)
      }
      else{
          self.push(id: Storyboard.Ids.CreateWalletViewController, animation: true)
      }
  }

  @IBAction func nextButtonTapped(_ sender: Any) {
    onBoardingPageViewController?.turnPage(to: pageControl.currentPage + 1, direction: .forward)
  }

  @IBAction func btnBackAction(_ sender: Any) {
    onBoardingPageViewController?.turnPage(to: pageControl.currentPage - 1, direction: .reverse)
  }

}
//MARK: -extension
extension OnboardingViewController {
  func initialLoads() {
    setDesign()
    localize()
  }

  func setDesign() {
//    Common.setFont(to: btnSkip!)
//    Common.setFont(to: btnGetStarted!)

  }
  func localize() {
    self.btnSkip.setTitle(Constants.string.skip.localize(), for: .normal)
    self.btnGetStarted.setTitle(Constants.string.getStarted.localize(), for: .normal)
    btnForward.setImage(UIImage(named: "buttonForward"), for: .normal)

  }
}
//MARK: -extension onboardingPageViewControllerDelegate
extension OnboardingViewController: onboardingPageViewControllerDelegate {

  func setupPageController(numberOfPage: Int) {
    pageControl.numberOfPages = numberOfPage
  }

  func turnPageController(to index: Int) {
    pageControl.currentPage = index
    btnGetStarted.isHidden = index == 2 ? false : true
    btnForward.isHidden = index == 2 ? true : false

  }
}

extension OnboardingViewController: PostViewProtocol {
  func onError(api: Base, message: String, statusCode code: Int) {

  }
}
