//
//  ViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 11/21/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bannerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initView()
    }
    func initView()
    {
        bannerView.setNeedsLayout()
        bannerView.setNeedsUpdateConstraints()
        let bannerView1 = LCBannerView.init(frame: CGRectMake(0,0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width * 0.77), delegate: nil, imageName: "splash", count: 4, timeInterval: 3, currentPageIndicatorTintColor: UIColor.orangeColor(), pageIndicatorTintColor: UIColor.whiteColor())
        bannerView1.pageDistance = 20
        bannerView.addSubview(bannerView1)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

