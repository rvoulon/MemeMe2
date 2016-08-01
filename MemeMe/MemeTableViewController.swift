//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Roberta Voulon on 2016-07-28.
//  Copyright © 2016 Roberta Voulon. All rights reserved.
//

import UIKit

private let memeTableViewCell = "MemeTableViewCell"
private let viewMemeViewController = "ViewMemeViewController"

class MemeTableViewController: UITableViewController {

    private var memes: [Meme] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(memeTableViewCell, forIndexPath: indexPath)
        
        // get the meme for the cell to be returned
        let meme = memes[indexPath.row]
        
        // configure the cell before returning it
        cell.imageView?.image = meme.sourceImage
        cell.textLabel?.text = meme.upperText
        cell.detailTextLabel?.text = meme.bottomText
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // get target view controller from storyboard
        let memeVC = storyboard!.instantiateViewControllerWithIdentifier(viewMemeViewController) as! ViewMemeViewController
        
        // pass the selected meme to the target view controller
        memeVC.meme = memes[indexPath.item]
        
        // present the view controler using navigation
        navigationController!.pushViewController(memeVC, animated: true)

    }

}
