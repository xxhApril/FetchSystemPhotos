//
//  HsuAlbumMasterTableViewController.swift
//  SystemAlbum
//
//  Created by Bruce on 2017/4/4.
//  Copyright © 2017年 Bruce. All rights reserved.
//

/// 获取所有相册

import UIKit
import Photos

typealias HandlePhotos = ([PHAsset], [UIImage]) -> Void
class HandleSelectionPhotosManager: NSObject {
    static let share = HandleSelectionPhotosManager()
    
    var maxCount: Int = 0
    var callbackPhotos: HandlePhotos?
    
    private override init() {
        super.init()
    }
    
    func getSelectedPhotos(with count: Int, callback completeHandle: HandlePhotos? ) {
        // 限制图片数量
        maxCount = count < 1 ? 1 : (count > 9 ? 9 : count)
        self.callbackPhotos = completeHandle
    }
}


enum AlbumTransformChina: String {
    case Favorites
    case RecentlyDeleted = "Recently Deleted"
    case Screenshots
    
     func chinaName() -> String {
        switch  self {
        case .Favorites:
            return "最爱"
        case .RecentlyDeleted:
            return "最近删除"
        case .Screenshots:
            return "手机截屏"
        }
    }
}

/// 相册类型
///
/// - albumAllPhotos: 所有
/// - albumSmartAlbums: 智能
/// - albumUserCollection: 收藏
enum AlbumSession: Int {
    case albumAllPhotos = 0
 //   case albumSmartAlbums
    case albumUserCollection
    
    static let count = 2
}

class HsuAlbumMasterTableViewController: UITableViewController {
    
    // MARK: - 👉Properties
    fileprivate var allPhotos: PHFetchResult<PHAsset>!
    fileprivate var smartAlbums: PHFetchResult<PHAssetCollection>!
    fileprivate var userCollections: PHFetchResult<PHCollection>!
    private let sectionTitles = ["", "智能相册", "相册"]
    
    fileprivate var MaxCount: Int = 0
    fileprivate var handleSelectionAction: (([String], [String]) -> Void)?

    // MARK: - 👉Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addCancleItem()
        
        fetchAlbumsFromSystemAlbum()
    }

    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // MARK: - 👉Private
    /// 获取所有系统相册概览信息
    private func fetchAlbumsFromSystemAlbum() {
        let allPhotoOptions = PHFetchOptions()
        // 时间排序
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
        
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        // 监测系统相册增加，即使用期间是否拍照
        PHPhotoLibrary.shared().register(self)
        
        // 注册cell
        tableView.register(MasterTableViewCell.self, forCellReuseIdentifier: MasterTableViewCell.cellIdentifier)
    }
    
    
    /// 添加取消按钮
    private func addCancleItem() {
        let barItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dismissAction))
        navigationItem.rightBarButtonItem = barItem
    }
    func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 👉UITableViewDelegate & UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return AlbumSession.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AlbumSession(rawValue: section)! {
        case .albumAllPhotos: return 1
    //    case .albumSmartAlbums: return smartAlbums.count
        case .albumUserCollection: return userCollections.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MasterTableViewCell.cellIdentifier, for: indexPath) as! MasterTableViewCell
        cell.selectionStyle = .none
 
        switch AlbumSession(rawValue: indexPath.section)! {
        case .albumAllPhotos:
            cell.asset = allPhotos.firstObject
            cell.albumTitleAndCount = ("所有照片", allPhotos.count)
//        case .albumSmartAlbums:
//            let collection = smartAlbums.object(at: indexPath.row)
//            cell.asset = PHAsset.fetchAssets(in: collection, options: nil).firstObject
//            cell.albumTitleAndCount = (collection.localizedTitle, PHAsset.fetchAssets(in: collection, options: nil).count)
        case .albumUserCollection:
            let collection = userCollections.object(at: indexPath.row)
            cell.asset = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: nil).firstObject
            cell.albumTitleAndCount = (collection.localizedTitle, PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: nil).count)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let gridVC = HsuAssetGridViewController()
        switch AlbumSession(rawValue: indexPath.section)! {
        case .albumAllPhotos:
            gridVC.fetchAllPhtos = allPhotos
//        case .albumSmartAlbums:
//            gridVC.assetCollection = smartAlbums.object(at: indexPath.row)
//            gridVC.fetchAllPhtos = PHAsset.fetchAssets(in: gridVC.assetCollection!, options: nil)
        case .albumUserCollection:
            gridVC.assetCollection = userCollections.object(at: indexPath.row) as? PHAssetCollection
            gridVC.fetchAllPhtos = PHAsset.fetchAssets(in: gridVC.assetCollection!, options: nil)
        }
        let currentCell = tableView.cellForRow(at: indexPath) as! MasterTableViewCell
        gridVC.title = currentCell.albumTitleAndCount?.0
        navigationController?.pushViewController(gridVC, animated: true)
        
    }

}

// MARK: - 👉PHPhotoLibraryChangeObserver
extension HsuAlbumMasterTableViewController: PHPhotoLibraryChangeObserver {
    /// 系统相册改变
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
               allPhotos = changeDetails.fetchResultAfterChanges
            }
//            
//            if let changeDetail = changeInstance.changeDetails(for: smartAlbums) {
//                smartAlbums = changeDetail.fetchResultAfterChanges
//                tableView.reloadSections(IndexSet(integer: AlbumSession.albumSmartAlbums.rawValue), with: .automatic)
//            }
            
            if let changeDetail = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetail.fetchResultAfterChanges
                tableView.reloadSections(IndexSet(integer: AlbumSession.albumUserCollection.rawValue), with: .automatic)
            }
        }
    }
}

// MARK: - 👉MasterTableViewCell
class MasterTableViewCell: UITableViewCell {
    static let cellIdentifier = "MasterTableViewCellIdentifier"
    
    private var firstImageView: UIImageView?
    private var albumTitleLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateUI()
    }
    
    private func updateUI() {
        let width = bounds.height
        firstImageView?.frame = CGRect(x: 0, y: 0, width: width, height: width)
        albumTitleLabel?.frame = CGRect(x: firstImageView!.frame.maxX + 5, y: 4, width: 200, height: width)
    }
    
    
    private func setupUI() {
        firstImageView = UIImageView()
        addSubview(firstImageView!)
        firstImageView?.clipsToBounds = true
        firstImageView?.contentMode = .scaleAspectFill
        
        albumTitleLabel = UILabel()
        albumTitleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(albumTitleLabel!)
    }
    
    
    // 展示第一张图片和标题
    var asset: PHAsset? {
        willSet {
        
            if newValue == nil {
                firstImageView?.image = #imageLiteral(resourceName: "l_picNil")
                return
            }
            let defaultSize = CGSize(width: UIScreen.main.scale + bounds.height, height: UIScreen.main.scale + bounds.height)
            PHCachingImageManager.default().requestImage(for: newValue!, targetSize: defaultSize, contentMode: .aspectFill, options: nil, resultHandler: { (img, _) in
            self.firstImageView?.image = img
           })
        }
    }
    
    var albumTitleAndCount: (String?, Int)? {
        willSet {
            if newValue == nil {
                return
            }
            self.albumTitleLabel?.text = (newValue!.0 ?? "") + " (\(String(describing: newValue!.1)))"
        }
    }
}
