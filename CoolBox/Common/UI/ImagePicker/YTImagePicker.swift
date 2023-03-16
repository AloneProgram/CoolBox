//
//  YTImagePicker.swift
//  Livepush
//
//  Created by winter on 2020/5/20.
//  Copyright © 2020 yeting. All rights reserved.
//

import UIKit
import TZImagePickerController

enum YTImagePickerType {
    case photo
    case video
    case photo_video
}

enum YTImagePickerCropType {
    case none
    case a9_16
    case aSquare
    
    var allowCrop: Bool {
        return self != .none
    }
    
    var cropRect: CGRect {
        switch self {
        case .none: return .zero
        case .a9_16: return CGRect(origin: CGPoint.zero, size: .zero)
        case .aSquare: return CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100))
        }
    }
}

struct YTImagePicker {
    typealias Result = (_ coverImage: UIImage?, _ asset: PHAsset?) -> Void
    
    /// cropType 为 非 none 时，type 仅支持 photo
    static func show(destVC vc: UIViewController,
                     type: YTImagePickerType = .photo_video,
                     cropType: YTImagePickerCropType = .none,
                     result: @escaping YTImagePicker.Result) {
        let doDelegate = YTImagePickerDoDelegate(result)
        let pickerType: YTImagePickerType = cropType.allowCrop ? .photo : type
        guard let pickerVC = generatePickerVC(pickerType,
                                              cropType: cropType,
                                              delegate: doDelegate) else { return }
        vc.doDelegate = doDelegate
        pickerVC.modalPresentationStyle = .fullScreen
        vc.present(pickerVC, animated: true)
    }
}

private extension YTImagePicker {
    static func generatePickerVC(_ type: YTImagePickerType,
                                 cropType: YTImagePickerCropType = .none,
                                 delegate: TZImagePickerControllerDelegate) -> TZImagePickerController? {
        guard let pickerVC = TZImagePickerController(maxImagesCount: 1, delegate: delegate) else {
            return nil
        }
        
        pickerVC.iconThemeColor = EColor.themeColor
        pickerVC.oKButtonTitleColorNormal = EColor.themeColor
        pickerVC.oKButtonTitleColorDisabled = EColor.themeColor.withAlphaComponent(0.7)
//        pickerVC.showSelectedIndex = true
        
        pickerVC.showSelectBtn = true
        pickerVC.showPhotoCannotSelectLayer = true
        pickerVC.cannotSelectLayerColor = UIColor.white.withAlphaComponent(0.5)
        pickerVC.needShowStatusBar = true
        
        pickerVC.preferredLanguage = "zh-Hans"
        
        pickerVC.allowTakePicture = false
        pickerVC.allowTakeVideo = false
        pickerVC.allowCameraLocation = false
        pickerVC.isSelectOriginalPhoto = true
        pickerVC.allowPickingOriginalPhoto = false
        // 允许多选视频时，预览就没有 slider
//        pickerVC.allowPickingMultipleVideo = true
        
        if type == .photo {
            pickerVC.allowPickingImage = true
            pickerVC.allowPickingVideo = false
        }
        else if type == .video {
            pickerVC.allowPickingImage = false
            pickerVC.allowPickingVideo = true
        }
        
        if cropType.allowCrop {
            pickerVC.allowCrop = true
            pickerVC.showSelectBtn = false
            pickerVC.cropRect = cropType.cropRect
        }

        do {
            pickerVC.photoSelImage = pickerVC.showSelectedIndex ? UIImage(named: "icon_picker_number_bg") : UIImage(named: "icon_picker_prevc_sel")
            pickerVC.photoOriginSelImage = UIImage(named: "icon_picker_original_sel")
        }
        return pickerVC
    }
}

fileprivate class YTImagePickerDoDelegate: NSObject, TZImagePickerControllerDelegate {
    
    var coverImage: UIImage?
    var sourceAsset: PHAsset?
    
    var result: YTImagePicker.Result
    init(_ result: @escaping YTImagePicker.Result) {
        self.result = result
    }
    
    func doResult() {
        result(coverImage, sourceAsset)
    }
    
    // MARK: - TZImagePickerControllerDelegate
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.coverImage = coverImage
        self.sourceAsset = asset
        doResult()
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.coverImage = photos.first
        if let asset = assets.first as? PHAsset {
            self.sourceAsset = asset
        }
        doResult()
    }
    
//    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
//        self.coverImage = photos.first
//        if let asset = assets.first as? PHAsset {
//            self.sourceAsset = asset
//        }
//        doResult()
//    }
    
    func isAssetCanSelect(_ asset: PHAsset!) -> Bool {
        return true
    }
}

// MARK: - YTImagePickerDoDelegate runtime
fileprivate struct YTImagePickerDoDelegateKey {
    static let rawValue = UnsafeRawPointer(bitPattern: "YTImagePickerDoDelegateKey".hashValue)
}

fileprivate extension UIViewController {
    var doDelegate: YTImagePickerDoDelegate? {
        set{
            guard let key = YTImagePickerDoDelegateKey.rawValue else { return }
            if let obj = newValue {
                objc_setAssociatedObject(self, key, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get{
            guard let key = YTImagePickerDoDelegateKey.rawValue else { return nil }
            return objc_getAssociatedObject(self, key) as? YTImagePickerDoDelegate
        }
    }
}

