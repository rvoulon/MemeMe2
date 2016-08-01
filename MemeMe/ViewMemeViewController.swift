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
    private let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName : NSNumber(float: -3.0)
    ]

    @IBOutlet weak var memeImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        memeImage.image = meme?.memedImage
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
