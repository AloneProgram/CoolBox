//
//  UploadPhotoView.swift
//  JHPhotos
//
//  Created by winter on 2017/6/30.
//  Copyright © 2017年 DJ. All rights reserved.
//

import UIKit

public final class UploadPhotoView: UIView {
    
    public weak var delegate: (JHUploadPhotoViewDelegate & JHUploadPhotoDataDelegate)? {
        didSet {
            if let obj = delegate {
                self.jp_viewController = SystemHelper.getCurrentPresentingVC(obj)
                uploadPhotoMaxCount = obj.maxDisplayUPloadPhotoNumber()
            }
        }
    }
    public var isDirectDisplayPhotoAlbum = true // 是否直接进入相册选择照片
    /// 选中图片数
    public var hasSelectImageCnt = 0
    /// 显示tips
    public var showTips = false
    
    fileprivate weak var jp_viewController: UIViewController?
    
    fileprivate var lineImageCount: CGFloat = 3
    fileprivate let minSpace: CGFloat = 10
    fileprivate let cellReuseIdentifier = "UploadImageCell"
    fileprivate var photoCollectionView: DragCellCollectionView!
    fileprivate var viewLayout: UICollectionViewFlowLayout! = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.minimumLineSpacing = 10
        viewLayout.minimumInteritemSpacing = 10
        return viewLayout
    }()
    
    fileprivate var uploadPhotoMaxCount = 0
    fileprivate var browserPhotos: [Photo] = []
    fileprivate var uploadCellPhotos: [UploadCellImage] = [] {
        didSet {
            hasSelectImageCnt = uploadCellPhotos.count
        }
    }
    
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.my_bundleImage(named: "jp_icon_upload_add"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    fileprivate lazy var tips: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = UIColor(hexString: "#000000", alpha: 0.6)
        lab.textAlignment = .center
        lab.font = Font(12)
        lab.text = "商品主图"
        lab.textColor = .white
        return lab
    }()
    
    fileprivate var selfWidth: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    func setupViews() {
        // 解决collectionView 下移64问题
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UIColor.clear
        self.addSubview(view)
        
        let width = self.bounds.width
        let itemW = (width-((lineImageCount - 1) * minSpace)) / lineImageCount
        viewLayout.itemSize = CGSize(width: itemW, height: itemW)
        photoCollectionView = DragCellCollectionView(frame: CGRect(x: 0, y: 0, width: width, height: itemW), collectionViewLayout: viewLayout)
        self.addSubview(photoCollectionView);
        photoCollectionView.myDelegate = self as DragCellCollectionViewDelegate
        photoCollectionView.myDataSource = self as DragCellCollectionViewDataSource
        photoCollectionView.register(UploadImageCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        addButton.addTarget(self, action: #selector(startSelectImage), for: .touchUpInside)
        self.addSubview(addButton)
        self.layer.masksToBounds = false
        
        self.addSubview(tips)
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if selfWidth < 1 {
            let width = self.bounds.width
            selfWidth = width
            let itemW = (width-((lineImageCount - 1) * minSpace)) / lineImageCount
            viewLayout.itemSize = CGSize(width: itemW, height: itemW)
            self.updateSelfViewHeight()
        }
    }
    
    // MARK: - public
    
    public init(_ frame: CGRect, delegate: (JHUploadPhotoDataDelegate & JHUploadPhotoViewDelegate)?, lineImgCount: CGFloat = 3) {
        self.lineImageCount = lineImgCount
        super.init(frame: frame)
        if let d = delegate {
            self.delegate = d
        }
        setupViews()
    }

    public func setupImageViews(_ imageUrls: [String]) {
        if imageUrls.count == 0 {
            return
        }
        
        uploadCellPhotos.removeAll()
        browserPhotos.removeAll()
        for url in imageUrls {
            if let Url = URL(string: url) {
                browserPhotos.append(Photo(url: Url))
                uploadCellPhotos.append(UploadCellImage(url))
            }
        }
        photoCollectionView.reloadData()
        self.updateSelfViewHeight()
    }
}

extension UploadPhotoView: DragCellCollectionViewDelegate, DragCellCollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploadCellPhotos.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! UploadImageCell
        cell.setImage(uploadCellPhotos[indexPath.item], photo: browserPhotos[indexPath.item])
        
        cell.deletedAction = { [weak self] () in
            self?.browserPhotos.enumerated().forEach({ (idx, photo) in
                if cell.photo == photo {
                    self?.deleteImageCell(idx)
                }
            })
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.handlePhotoBrowser(indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndex: Int, to destinationIndex: Int) {
        //print("moveItemAt = \(sourceIndex+1), to = \(destinationIndex+1)")
        // UI更新位置，这里并不是交换
        
        let item = uploadCellPhotos[sourceIndex]
        uploadCellPhotos.remove(at: sourceIndex)
        uploadCellPhotos.insert(item, at: destinationIndex)

        let bitem = browserPhotos[sourceIndex]
        browserPhotos.remove(at: sourceIndex)
        browserPhotos.insert(bitem, at: destinationIndex)
//        if let image = item.cellImage {
//           browserPhotos.insert(Photo(image: image), at: destinationIndex)
//        }

        self.delegate?.moveItemAt(sourceIndex, to: destinationIndex)
    }
    
    public func collectionView(_ collectionView: UICollectionView, deleteItemAt index: Int) {
        deleteImageCell(index)
    }
}

fileprivate extension UploadPhotoView {
    
    func updateSelfViewHeight() {
        let itemH = viewLayout.itemSize.height
        
//        let lineCount = uploadCellPhotos.count % Int(lineImageCount) == 0 ? uploadCellPhotos.count / Int(lineImageCount) : uploadCellPhotos.count / Int(lineImageCount) + 1
//        let columnCount = uploadCellPhotos.count % Int(lineImageCount)
        var lineCount = 0
        var columnCount = 0
        var extra = 1
        if needUploadPhotoCount() != 0 {
            addButton.isHidden = false
            lineCount = (uploadCellPhotos.count + 1) % Int(lineImageCount) == 0 ? (uploadCellPhotos.count + 1) / Int(lineImageCount) : (uploadCellPhotos.count + 1) / Int(lineImageCount) + 1
            columnCount = uploadCellPhotos.count % Int(lineImageCount)
            
            let buttonX: CGFloat = (itemH + minSpace) * CGFloat(columnCount)
            let buttonY: CGFloat = (itemH + minSpace) * CGFloat(lineCount - extra)
            addButton.frame = CGRect(x: buttonX, y: buttonY, width: itemH, height: itemH)
        }
        else {
            // 不能再继续上传了
            extra = 0
            lineCount = uploadCellPhotos.count % Int(lineImageCount) == 0 ? uploadCellPhotos.count / Int(lineImageCount) : uploadCellPhotos.count / Int(lineImageCount) + 1
            columnCount = uploadCellPhotos.count % Int(lineImageCount)
            addButton.isHidden = true
        }
        
        if uploadCellPhotos.count == 0 {
            tips.isHidden = true
        }else {
            if showTips {
                tips.isHidden = false
                let itemH = viewLayout.itemSize.height
                tips.frame = CGRect(x: 0, y: itemH - 25, width: itemH, height: 25)
                let corners: UIRectCorner = [.bottomLeft, .bottomRight]
                let path = UIBezierPath(roundedRect: tips.bounds,
                                        byRoundingCorners: corners,
                                        cornerRadii: CGSize(width: 5, height: 5))
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                tips.layer.mask = mask
            }else {
                tips.isHidden = true
            }
        }
        
        let height = itemH * CGFloat(lineCount) + minSpace * CGFloat(lineCount - 1)
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
        photoCollectionView.frame = self.bounds
        delegate?.uploadPhotoView(viewHeight: height)
    }
    
    func needUploadPhotoCount() -> Int {
        let num = uploadPhotoMaxCount - uploadCellPhotos.count
        return max(0, num)
    }
    
    func addImageDatas(_ datas: [JPhoto]) {
        if jp_viewController == nil {
            return
        }
        let screen = UIScreen.main
        let scale = screen.scale
        let imageSize = max(screen.bounds.width, screen.bounds.height) * 1.5
        let imageTargetSize = CGSize(width: imageSize * scale, height: imageSize * scale)
        
        var cellImages: [UploadCellImage] = []
//        for (idx, photo) in datas.enumerated() {
        for photo in datas {
            if let data = photo.imageData {
                browserPhotos.append(Photo(data: data))
                cellImages.append(UploadCellImage(data))
            }
            else if let asset = photo.asset {
                browserPhotos.append(Photo(asset: asset, targetSize: imageTargetSize))
                cellImages.append(UploadCellImage(asset))
            }
//            self.delegate?.willUploadSingle(photo, idx: idx)
        }
        let index = uploadCellPhotos.count
        uploadCellPhotos.insert(contentsOf: cellImages, at: index)
        updateSelfViewHeight()
        photoCollectionView.reloadData()
        
        self.delegate?.willUploadAll(datas)
    }
    
    func deleteImageCell(_ index: Int) {
        browserPhotos.remove(at: index)
        uploadCellPhotos.remove(at: index)
        updateSelfViewHeight()
        photoCollectionView.reloadData()
        self.delegate?.deletePhotoView(index)
    }
    
    // MARK: - action 选择图片

    @objc func startSelectImage() {
        guard let vc = jp_viewController else {
            return print("UploadPhotoView delegate(viewController) must not be nil")
        }
        if !isDirectDisplayPhotoAlbum {
            
            let alert = SelectAlert()
            let cancel = SelectAlertAction(title: "取消", type: .cancel)
            let takePhoto  = SelectAlertAction(title: "拍照") { [weak self] in
                self?.takePhoto()
            }
            let selectPhoto  = SelectAlertAction(title: "从手机相册选择") { [weak self] in
                self?.selectPhoto()
            }
            
            alert.addAction(takePhoto)
            alert.addAction(selectPhoto)
            alert.addAction(cancel)
            alert.show()
        }
        else {
            func showPhotoAlbumViewController()  {
                let nvc = PhotoAlbumViewController.photoAlbum(maxSelectCount: self.needUploadPhotoCount()) { [weak self] (datas) in
                    self?.addImageDatas(datas)
                }
                AppCommon.getCurrentVC()?.present(nvc, animated: true, completion: nil)
            }
            
            SystemHelper.verifyPhotoLibraryAuthorization({ showPhotoAlbumViewController() })
        }
    }
    
    func handlePhotoBrowser(_ index: Int) {
        // 启动图片浏览器
        let photoBrowser = PhotoBrowser(delgegate: self)
        photoBrowser.setCurrentPageIndex(index)
        photoBrowser.canSavePhoto = false
        let nav = UINavigationController(rootViewController: photoBrowser)
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .fullScreen
        self.jp_viewController?.present(nav, animated: true, completion: nil)
    }
}

extension UploadPhotoView: JHPhotoBrowserDelegate {
    public func numberOfPhotosInPhotoBrowser(_ photoBrowser: PhotoBrowser) -> Int {
        return browserPhotos.count
//        return uploadCellPhotos.count
    }
    
    public func photoBrowser(_ photoBrowser: PhotoBrowser, photoAtIndex: Int) -> Photo? {
        if photoAtIndex < browserPhotos.count {
            return browserPhotos[photoAtIndex]
        }
//        if photoAtIndex < uploadCellPhotos.count {
//            let temp = uploadCellPhotos[photoAtIndex]
//            if let image = temp.cellImage {
//                return Photo(image: image)
//            }
//            else if let data = temp.cellImageData {
//                return Photo(data: data)
//            }
//            else  if let string = temp.cellImageUrl, let url = URL(string: string) {
//                return Photo(url: url)
//            }
//            else if let asset = temp.cellAsset {
//                let screen = UIScreen.main
//                let scale = screen.scale
//                let imageSize = max(screen.bounds.width, screen.bounds.height) * 1.5
//                let imageTargetSize = CGSize(width: imageSize * scale, height: imageSize * scale)
//                return Photo(asset: asset, targetSize: imageTargetSize)
//            }
//            return nil
//        }
        return nil
    }
    
    public func photoBrowserDeleteImage(_ photoBrowser: PhotoBrowser, photoAtIndex: Int) {
        deleteImageCell(photoAtIndex)
    }
}

fileprivate extension UploadPhotoView {
    
    func takePhoto() {
        // 拍照
        func doit() {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .camera
//            imagePickerVC.allowsEditing = true
            imagePickerVC.delegate = self
            jp_viewController?.present(imagePickerVC, animated: true, completion: nil)
        }
        
        SystemHelper.verifyCameraAuthorization({ doit() })
    }
    
    func selectPhoto() {
        let maxSelectCount = needUploadPhotoCount()
        // 相册
        func doit() {
            let vc = PhotoAlbumViewController.photoAlbum(maxSelectCount: maxSelectCount, block: { [weak self] (datas) in
                self?.addImageDatas(datas)
            })
            vc.modalPresentationStyle = .fullScreen
            jp_viewController?.present(vc, animated: true, completion: nil)
        }
        
        SystemHelper.verifyPhotoLibraryAuthorization({ doit() })
    }
}

extension UploadPhotoView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
//        if let imageData = image.jpegData(compressionQuality: 0.5) {
//            picker.dismiss(animated: true) { [weak self] () in
//                self?.addImageDatas([JPhoto(imageData)])
//            }
//            return
//        }
//        picker.dismiss(animated: true, completion: nil)
        
        picker.dismiss(animated: false, completion: nil)
        let image = info[.originalImage] as! UIImage
        let cropperImage = RImageCropperViewController(originalImage: image, cropFrame: CGRect.init(x: (kScreenWidth - 300)/2, y: (kScreenHeight - 300)/2, width: 300, height: 300), limitScaleRatio: 30)
        cropperImage.delegate = self
        jp_viewController?.push(cropperImage)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension UploadPhotoView : RImageCropperDelegate {
    func imageCropper(cropperViewController: RImageCropperViewController, didFinished editImg: UIImage) {
        if let imageData = editImg.jpegData(compressionQuality: 0.5) {
            self.addImageDatas([JPhoto(imageData)])
        }
        cropperViewController.navigationController?.popViewController(animated: false)
    }
    
    func imageCropperDidCancel(cropperViewController: RImageCropperViewController) {
        cropperViewController.navigationController?.popViewController(animated: false)
    }
}
