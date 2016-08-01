//
//  ViewMemeViewController.swift
//  MemeMe
//
//  Created by Roberta Voulon on 2016-07-22.
//  Copyright © 2016 Roberta Voulon. All rights reserved.
//

import UIKit

class ViewMemeViewController: UIViewController {
    
    var meme: Meme?
    
    @IBOutlet weak var memeImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        memeImage.image = meme?.memedImage
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
