//
//  ViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 11/21/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    static let password = "2505"
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var confettiArea: L360ConfettiArea!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bannerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initView()
    }
    func initView()
    {
        loginView.layer.cornerRadius = 8
        loginBtn.layer.cornerRadius = 8
        
        bannerView.setNeedsLayout()
        bannerView.setNeedsUpdateConstraints()
        let bannerView1 = LCBannerView.init(frame: CGRectMake(0,0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width * 0.77), delegate: nil, imageName: "splash", count: 4, timeInterval: 3, currentPageIndicatorTintColor: UIColor.orangeColor(), pageIndicatorTintColor: UIColor.whiteColor())
        bannerView1.pageDistance = 20
        bannerView.addSubview(bannerView1)
        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.HandleTap))
        
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func shareAction(sender: AnyObject) {
        
        hiddenLoginView(false)
        
    }
    func HandleTap(recogizer: UITapGestureRecognizer) {
        let tapPoint = recogizer.locationInView(self.view)
        self.confettiArea.blastSpread = 0.5
        self.confettiArea.blastFrom(tapPoint, towards: 3.14/2.0, withForce: 400.0, confettiWidth: 5.0, numberOfConfetti: 60)
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        if txtPassword.text != ViewController.password
        {
            showAlertMessage("", title: "Incorrect Password! Please try again!")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let funVC = storyboard.instantiateViewControllerWithIdentifier("FindFunPlaceViewController") as? FindFunPlaceViewController
        self.navigationController?.pushViewController(funVC!, animated: true)
        hiddenLoginView(true)
        txtPassword.text = ""
        // hide keyboard...
        self.view.endEditing(true)
        
        
    }
    
    @IBAction func loginDialogCloseAction(sender: AnyObject) {
        hiddenLoginView(true)
        // hide keyboard...
        self.view.endEditing(true)
    }
    func showAlertMessage(message: String!, title: String!)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    func hiddenLoginView(flag: Bool)
    {
        loginView.hidden = flag
        blockView.hidden = flag
    }
    
}

