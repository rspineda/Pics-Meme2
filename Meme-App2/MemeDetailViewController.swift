//
//  MemeDetailViewController.swift
//  Meme-App2
//
//  Created by Ronald Pineda on 13/01/22.
//

import Foundation

import UIKit

// MARK: - MemeDetailViewController: UIViewController

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var showImage:UIImage! = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imgView.image = showImage
    }
    
}
