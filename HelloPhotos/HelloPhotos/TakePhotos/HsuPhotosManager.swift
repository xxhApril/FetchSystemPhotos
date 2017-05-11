//
//  HsuPhotosManager.swift
//  HelloPhotos
//
//  Created by goWhere on 2017/5/9.
//  Copyright © 2017年 iwhere. All rights reserved.
//

/// 选择照片方式

import UIKit

class HsuPhotosManager: NSObject {
    static let share = HsuPhotosManager()
    private override init() {
        super.init()
    }
    
    /// 添加图片
    ///
    /// - Parameters:
    ///   - phtotsCount: 几张
    ///   - showCamera: 是否相机
    ///   - showAlbum: 是否相册
    ///   - _completeHandler: 回调
    func takePhotos(_ photosCount: Int, _ showCamera: Bool, _ showAlbum: Bool, _ completeHandler: @escaping ([Data?]) -> Void) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if showAlbum {
            alertVC.addAction(UIAlertAction(title: "相册选择", style: .default, handler: { (action) in
                self.openSystemAlbum(photosCount, { datas in
                    completeHandler(datas)
                })
            }))
        }

        if showCamera {
            alertVC.addAction(UIAlertAction(title: "相机", style: .default, handler: { (action) in
                DispatchQueue.main.async {
                    let cameraVC = HsuCameraViewController()
                    cameraVC.callbackPicutureData = { imgData in
                        completeHandler([imgData])
                    }
                    UIApplication.shared.keyWindow?.currentViewController()?.present(cameraVC, animated: true, completion: nil)
                    
                }
            }))
        }

        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        
        UIApplication.shared.keyWindow?.currentViewController()?.present(alertVC, animated: true, completion: nil)
    }
    
    private func openSystemAlbum(_ photoCount: Int, _ callback: @escaping (([Data?]) -> Void)) {
        let masterVC = HsuAlbumMasterTableViewController()
        let navi = UINavigationController(rootViewController: masterVC)
        masterVC.title = "图片"
        let gridVC = HsuAssetGridViewController()
        gridVC.title = "所有图片"
        navi.pushViewController(gridVC, animated: false)
        
        UIApplication.shared.keyWindow?.currentViewController()?.present(navi, animated: true)
        
        HandleSelectionPhotosManager.share.getSelectedPhotos(with: photoCount) { (assets, images) in
            var datas = [Data?]()
            images.forEach({ img in
                let imgData = UIImageJPEGRepresentation(img, 0.2)
                datas.append(imgData)
            })
            callback(datas)
        }
    }
}

// 获取当前UIViewController
/** @abstract UIWindow hierarchy category.  */
public extension UIWindow {
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
    public func topMostController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    /** @return Returns the topViewController in stack of topMostController.    */
    public func currentViewController()->UIViewController? {
        
        var currentViewController = topMostController()
        
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        
        return currentViewController
    }
}
