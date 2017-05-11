//
//  ViewController.swift
//  HelloPhotos
//
//  Created by goWhere on 2017/5/9.
//  Copyright © 2017年 iwhere. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var vcFlowLayout: UICollectionViewFlowLayout!
    
    var imgDatas = [Data?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vcFlowLayout.itemSize = CGSize(width: 80, height: 80)
        vcFlowLayout.minimumLineSpacing = 20
        vcFlowLayout.minimumInteritemSpacing = 20
    }

    @IBAction func oneAction(_ sender: UIButton) {
        imgDatas.removeAll()
        HsuPhotosManager.share.takePhotos(1, true, true) { (datas) in
            self.imgDatas.append(contentsOf: datas)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    @IBAction func mutableAction(_ sender: UIButton) {
        imgDatas.removeAll()
        HsuPhotosManager.share.takePhotos(7, true, true) { (datas) in
            self.imgDatas.append(contentsOf: datas)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgDatas.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CVCell.cellIdentifier, for: indexPath) as! CVCell
        cell.imageView.image = UIImage(data: imgDatas[indexPath.row] ?? Data())
        return cell
    }
}


class CVCell: UICollectionViewCell {
    static let cellIdentifier = "cellIdentifier"
    
    @IBOutlet weak var imageView: UIImageView!
    
}
