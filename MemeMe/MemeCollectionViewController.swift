//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Roberta Voulon on 2016-07-21.
//  Copyright © 2016 Roberta Voulon. All rights reserved.
//

//  Maybe later, nice to have?
//  TODO: add an edit button that launches the meme editor from the view meme view controller
//  TODO: show a background image if there are no memes to display
//  TODO: add a swipe to delete to the tableview


import UIKit

private let memeCollectionViewCell = "MemeCollectionViewCell"
private let viewMemeViewController = "ViewMemeViewController"

class MemeCollectionViewController: UICollectionViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private var memes: [Meme] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memes
    }

    private let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "Impact", size: 20)!,
        NSStrokeWidthAttributeName : NSNumber(float: -2.0)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
        
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()

        // Using flow layout to determine the cell size and layout
        let space: CGFloat = 0
        let screenSize = self.view.frame.size
        let itemWidth = screenSize.width / 3
        let itemHeight = screenSize.height / 5
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(memeCollectionViewCell, forIndexPath: indexPath) as! MemeCollectionViewCell
    
        // get the meme for the cell to be returned
        let meme = memes[indexPath.item]
        
        // configure the cell
        cell.memeImage.image = meme.sourceImage
        cell.memeLabelTop.attributedText = NSAttributedString(string: meme.upperText!, attributes: memeTextAttributes)
        cell.memeLabelBottom.attributedText = NSAttributedString(string: meme.bottomText!, attributes: memeTextAttributes)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // get target view controller from storyboard
        let memeVC = storyboard!.instantiateViewControllerWithIdentifier(viewMemeViewController) as! ViewMemeViewController
        
        // pass the selected meme to the target view controller
        memeVC.meme = memes[indexPath.item]
        
        // present the view controler using navigation
        navigationController!.pushViewController(memeVC, animated: true)
        
    }

}
