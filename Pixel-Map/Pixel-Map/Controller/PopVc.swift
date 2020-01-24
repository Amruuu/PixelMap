//
//  PopVc.swift
//  Pixel-Map
//
//  Created by Amr on 7/16/19.
//  Copyright © 2019 Amr. All rights reserved.
//

import UIKit

class PopVc: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var PopImageView: UIImageView!
    @IBOutlet weak var TheTitle: UILabel!
    var passedImage: UIImage!
    var passedTitle: String!
    
    func initData(forImage image: UIImage, forTitle title: String){
        self.passedImage = image
        self.passedTitle = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PopImageView.image = passedImage
        TheTitle.text = passedTitle
        addGestRec()
        // Do any additional setup after loading the view.
    }
    
    func addGestRec(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ScreenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
 
    @objc func ScreenWasDoubleTapped(){
        dismiss(animated: true, completion: nil)
    }
}
