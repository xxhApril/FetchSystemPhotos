//
//  ViewController.swift
//  FetchAlbums
//
//  Created by Bruce on 2017/4/4.
//  Copyright © 2017年 Bruce. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    var images = [UIImage]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fetchPhotosAction(_ sender: UIButton) {
        let masterVC = HsuAlbumMasterTableViewController()
        let navi = UINavigationController(rootViewController: masterVC)
        masterVC.title = "图片"
        let gridVC = HsuAssetGridViewController()
        gridVC.title = "所有图片"
        navi.pushViewController(gridVC, animated: false)
        
        present(navi, animated: true)
        
        
        /// 结果
        if sender.tag == 1 {
            HandleSelectionPhotosManager.share.getSelectedPhotos(with: 1) { (assets, images) in
                self.images = images
                self.collectionView.reloadData()
            }
        } else {
            HandleSelectionPhotosManager.share.getSelectedPhotos(with: 6) { (assets, images) in
                self.images = images
                self.collectionView.reloadData()
            }
        }
        
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestCollectionViewCell.cellIdentifer, for: indexPath) as! TestCollectionViewCell
        cell.selectedImageView.image = self.images[indexPath.item]
        return cell
    }
}

class TestCollectionViewCell: UICollectionViewCell {
    static let cellIdentifer = "TestCollectionViewCell"
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

