//
//  FeedViewController.swift
//  ios8_facebook_transitions
//
//  Created by Stanley Ng on 9/24/14.
//  Copyright (c) 2014 Stanley Ng. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var feedTabBarItem: UITabBarItem!
    @IBOutlet weak var albumContentView: UIView!
    var isPresenting = false
    var proxy: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("FeedViewController.viewDidLoad")
        setupScrollView()
        setupTabBar()
        
        proxy.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScrollView() {
        self.contentImageView.sizeToFit()
        self.scrollView.contentInset = UIEdgeInsets(top: 110, left: 0, bottom: 50, right: 0)
        self.scrollView.contentSize = self.contentImageView.frame.size
    }
    
    func setupTabBar() {
        self.tabBar.selectedItem = feedTabBarItem
    }

    @IBAction func onPhotoTap(sender: UITapGestureRecognizer) {
        println("FeedViewController.onPhotoTap")

        if sender.view is UIImageView {
            println("sender is UIImageView")

            var delta = self.albumContentView.convertPoint(CGPointZero, toView: view)
            println("delta = \(delta)")
            
            var current = (sender.view as UIImageView)
            proxy.contentMode = UIViewContentMode.ScaleAspectFit
            proxy.frame = CGRect(x: current.frame.origin.x + delta.x, y: current.frame.origin.y + delta.y, width: current.frame.width, height: current.frame.height)
            proxy.image = current.image
            proxy.tag = current.tag
            println("proxy = \(proxy)")
            
//            var v = UIView(frame: proxy.frame)
//            v.backgroundColor = UIColor.redColor()
//            view.addSubview(v)
        }
        
        performSegueWithIdentifier("PhotoFromFeed", sender: sender)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var destinationViewController = segue.destinationViewController as PhotoViewController

        // passing data
        var imageView = sender.view as UIImageView
        destinationViewController.image = imageView.image
        
        // customizing transition
        destinationViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        destinationViewController.transitioningDelegate = self
    }

    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        println("animateTransition")
        
        var containerView = transitionContext.containerView()
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if isPresenting {

            // initialize proxy image
            var window = UIApplication.sharedApplication().keyWindow
            proxy.hidden = false
            proxy.alpha = 1
            window.addSubview(proxy)

            // initialize target view
            toViewController = toViewController as PhotoViewController
            containerView.addSubview(toViewController.view)
            toViewController.view.alpha = 0
            (toViewController as PhotoViewController).imageView.alpha = 0
            (toViewController as PhotoViewController).imageView.tag = proxy.tag
            
            UIView.animateWithDuration(0.4,
                animations: {
                    () -> Void in

                    // animate proxy image
                    self.proxy.frame = (toViewController as PhotoViewController).imageView.frame

                    // animate target view
                    toViewController.view.alpha = 1
                    
                    // hide status bar
                    UIApplication.sharedApplication().statusBarHidden = true
                    
                },
                completion: {
                    (finished: Bool) -> Void in
  
                    println("1. animateTransition:completion")

                    // complete proxy image
                    UIView.animateWithDuration(0.2,
                        animations: {
                            () -> Void in
                            self.proxy.alpha = 0
                        },
                        completion: {
                            (finished: Bool) -> Void in
                            self.proxy.removeFromSuperview()
                            
                            UIView.animateWithDuration(0.4,
                                animations: {
                                    () -> Void in
                                    (toViewController as PhotoViewController).showControls()
                                },
                                completion: {
                                    (finished: Bool) -> Void in
                                    transitionContext.completeTransition(true)
                            })
                        }
                    )
                    
                    // complete target view
                    (toViewController as PhotoViewController).imageView.alpha = 1
                }
            )
        }
        else {
            println((fromViewController as PhotoViewController).imageView)
            
            // initialize proxy image
            var window = UIApplication.sharedApplication().keyWindow
            var v = UIView(frame: (fromViewController as PhotoViewController).imageView.frame)
            v.backgroundColor = UIColor.redColor()
//            println("v = \(v)")
//            window.addSubview(v)
            
            UIView.animateWithDuration(0.4,
                animations: {
                    () -> Void in
                    
                    // animate proxy image
                    
                    // animate target view
                    fromViewController.view.alpha = 0

                    // show status bar
                    UIApplication.sharedApplication().statusBarHidden = false

                },
                completion: {
                    (finished: Bool) -> Void in
                    
                    println("2. animateTransition:completion")
                    transitionContext.completeTransition(true)
                    fromViewController.view.removeFromSuperview()

                }
            )
        }
    }

}
