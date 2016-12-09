//
//  HelpViewController.swift
//  Kitu
//
//  Created by Rui Caneira on 12/1/16.
//  Copyright © 2016 Rui Caneira. All rights reserved.
//

import UIKit
import CharPageControl

class ExampleCell: UICollectionViewCell {
    @IBOutlet
    var pageImage: UIImageView!
}

class HelpViewController: UIViewController {
    
    var pageViewController: UIPageViewController?
    
    @IBOutlet weak var pageControl: UIPageControl!
    let pageCount:Int = 4
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension HelpViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? ExampleCell{
            let image = "help_0" + String(indexPath.row+1)
            cell.pageImage.image = UIImage(named: image)
            return cell
        }
        return ExampleCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount
    }
}

extension HelpViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentSize.width == 0
        {
            return
        }
        let currentPage = round((CGFloat(pageCount) * scrollView.contentOffset.x)/scrollView.contentSize.width)
        pageControl.currentPage = Int(currentPage)
    }
}

extension HelpViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height = collectionView.frame.size.height + 20
        return size
    }
}

