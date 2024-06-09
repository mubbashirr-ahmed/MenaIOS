//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//
import UIKit

protocol onboardingPageViewControllerDelegate: class {
  func setupPageController(numberOfPage: Int)
  func turnPageController(to index: Int)
}

class OnboardingPageViewController: UIPageViewController {

  weak var pageViewControllerDelagate: onboardingPageViewControllerDelegate?

  var pageTitle = [
    Constants.string.pageTitle1.localize(), Constants.string.pageTitle2.localize(),
    Constants.string.pageTitle3.localize(),
  ]

  var pageImages: [UIImage] = [
    UIImage(named: "Welcome1")!, UIImage(named: "Welcome2")!, UIImage(named: "Welcome3")!,
  ]

  var pageStepper: [UIImage] = [
    UIImage(named: "Stepper1")!, UIImage(named: "Stepper2")!, UIImage(named: "Stepper3")!,
  ]

  var pageDescriptionText = [
    Constants.string.pageDescriptionText1.localize(),
    Constants.string.pageDescriptionText2.localize(),
    Constants.string.pageDescriptionText3.localize(),
  ]

  var backgroundColor: [UIColor] = [.white, .white, .white]
  var currentIndex = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = self
    delegate = self
    if let firstViewController = contentViewController(at: 0) {
      setViewControllers(
        [firstViewController], direction: .forward, animated: true, completion: nil)
    }
  }

  func turnPage(to index: Int, direction: NavigationDirection = .forward) {
    currentIndex = index
    if let currentController = contentViewController(at: index) {
      setViewControllers([currentController], direction: direction, animated: true)
      self.pageViewControllerDelagate?.turnPageController(to: currentIndex)
    }
  }

}

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController
  ) -> UIViewController? {
    if var index = (viewController as? OnboardingContentViewController)?.index {
      index -= 1
      return contentViewController(at: index)
    }
    return nil
  }

  func pageViewController(
    _ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController
  ) -> UIViewController? {
    if var index = (viewController as? OnboardingContentViewController)?.index {
      index += 1
      return contentViewController(at: index)
    }
    return nil
  }

  func pageViewController(
    _ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
    previousViewControllers: [UIViewController], transitionCompleted completed: Bool
  ) {

    if let pageContentViewController = pageViewController.viewControllers?.first
      as? OnboardingContentViewController
    {
      currentIndex = pageContentViewController.index
      self.pageViewControllerDelagate?.turnPageController(to: currentIndex)
    }
  }

  func contentViewController(at index: Int) -> OnboardingContentViewController? {
    if index < 0 || index >= pageTitle.count {
      return nil
    }
    let storyBoard = UIStoryboard(name: "PreLogin", bundle: nil)
    if let pageContentViewController = storyBoard.instantiateViewController(
      withIdentifier: "onboardingContentVC") as? OnboardingContentViewController
    {
      pageContentViewController.image = pageImages[index]
      pageContentViewController.subHeading = pageDescriptionText[index]
      pageContentViewController.heading = pageTitle[index]
      pageContentViewController.bgColor = backgroundColor[index]
      pageContentViewController.index = index
      pageContentViewController.stepper = pageStepper[index]
      self.pageViewControllerDelagate?.setupPageController(numberOfPage: 3)
      return pageContentViewController
    }
    return nil
  }
}
