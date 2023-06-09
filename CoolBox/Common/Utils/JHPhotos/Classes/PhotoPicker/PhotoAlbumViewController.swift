//
//  PhotoAlbumViewController.swift
//  JHPhotos
//
//  Created by winter on 2017/6/29.
//  Copyright © 2017年 DJ. All rights reserved.
//

import UIKit
import Photos

private let cameraPickerIdentifier = "cameraPickerCell"
private let albumPickerIdentifier = "albumPickerCell"

public final class PhotoAlbumViewController: UICollectionViewController {
    
    // MARK: - public property
    
    public var maxSelectCount: Int = 3
    public var resultClosure: JPhotoResult?
    
    // MARK: - private property
    
    @IBOutlet fileprivate weak var titleButton: RightImageButton!
    @IBOutlet fileprivate weak var viewFlowLayout: UICollectionViewFlowLayout!
    
    fileprivate var selectedCount = 0 // 已经选中的照片数
    
    fileprivate var _uploadItems = NSMutableArray() // PhotoAlbum
    fileprivate var selectedPhotoStatus: [Bool] = [] // 照片是否被选中状态
    
    fileprivate var currentPhotoListAlbum: PhotoListAlbum?
    fileprivate lazy var albumSelectView: PhotoAlbumSelectView = {
        return PhotoAlbumSelectView.instance()
    }()
    
    fileprivate var browserPhotos: [Photo]!
    fileprivate var albumListCount = 0
    fileprivate var albumList: [PhotoAlbum]! {
        didSet {
            self.updateAlbumList(albumList.count)
        }
    }
    
    private func updateAlbumList(_ dataCount: Int) {
        selectedPhotoStatus.removeAll()
        albumListCount = dataCount
        for _ in 0..<dataCount {
            selectedPhotoStatus.append(false)
        }
    }
    
    public class func photoAlbum(maxSelectCount count: Int, block: @escaping JPhotoResult) -> UINavigationController {
        let nvc = UIStoryboard(name: "PhotoAlbum", bundle: SystemHelper.getMyLibraryBundle()).instantiateInitialViewController() as! UINavigationController
        nvc.navigationBar.barStyle = .black
        nvc.navigationBar.tintColor = .white
        let color = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
        nvc.navigationBar.setBackgroundImage(UIImage.color(color), for: .default)
        
        let vc = nvc.topViewController as! PhotoAlbumViewController
        vc.maxSelectCount = count
        vc.resultClosure = block
        return nvc
    }

    deinit {
        print("PhotoAlbumViewController deinit")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        titleButton.backgroundColor = UIColor.clear
        let width = (UIScreen.main.bounds.width - 3) / 4.0
        viewFlowLayout.itemSize = CGSize(width: width, height: width)
        
        self.loadAlbumUserLibraryData()
    }

    // MARK: UICollectionViewDataSource

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumListCount + 1
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: cameraPickerIdentifier, for: indexPath)
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: albumPickerIdentifier, for: indexPath) as! PhotoAlbumCell
            let model = albumList[indexPath.item - 1]
            model.canSelected = selectedCount < maxSelectCount || model.isSelected
            cell.setPhotoAlbum(model, selectBlock: { [weak self] (album) in
                guard let strongSlef = self else { return }
                if let album = album {
                    strongSlef.addUploadItem(album)
                }
                else { SystemHelper.showTip("你最多只能选择\(strongSlef.maxSelectCount)张图片！") }
            })
            return cell
        }
    }

    // MARK: UICollectionViewDelegate

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.item == 0 {
            return
        }
        let model = albumList[indexPath.item - 1]
        if model.canSelected {
            let photoBrowser = PhotoBrowser(delgegate: self)
            photoBrowser.isDisplaySelectionButton = true
            photoBrowser.setCurrentPageIndex(indexPath.item - 1)
//            let nav = UINavigationController(rootViewController: photoBrowser)
//            nav.modalTransitionStyle = .crossDissolve
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true, completion: nil)
            navigationController?.pushViewController(photoBrowser, animated: true)
        }
    }
}

// MARK: - private method

fileprivate extension PhotoAlbumViewController {
    // 获得相机胶卷
    func loadAlbumUserLibraryData() {
        if let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).lastObject {
            self.enumerateAssets(in: cameraRoll)
        }
    }
    
    func enumerateAssets(in assetCollection: PHAssetCollection) {
        let screen = UIScreen.main
        let scale = screen.scale
        // Sizing is very rough... more thought required in a real implementation
        let imageSize = max(screen.bounds.width, screen.bounds.height) * 1.5
        let imageTargetSize = CGSize(width: imageSize * scale, height: imageSize * scale)
        
        var array: [Photo] = []
        var albums: [PhotoAlbum] = []
        
        PhotoAlbumTool.enumerateAssets(in: assetCollection, ascending: false) { (obj, idx, stop) in
            let model = PhotoAlbum(obj)
            albums.append(model)
            array.append(Photo(asset: obj, targetSize: imageTargetSize))
        }
        albumList = albums
        browserPhotos = array
        
        self.setSelectCount(0)
        if let asset = albumList.first?.asset, currentPhotoListAlbum == nil  {
            currentPhotoListAlbum = PhotoListAlbum(title: assetCollection.localizedTitle,
                                                   count: albumList.count,
                                                   head: asset,
                                                   collection: assetCollection)
        }
    }
    
    // obj = nil -> 超出最大选取数
    func addUploadItem(_ obj: PhotoAlbum)  {
        if obj.isSelected {
           if !_uploadItems.contains(obj) {
                self.setSelectCount(selectedCount + 1)
                _uploadItems.add(obj)
            }
        }
        else {
            self.setSelectCount(selectedCount - 1)
            _uploadItems.remove(obj)
        }
        
        if let index = self.albumList.firstIndex(of: obj) {
            self.selectedPhotoStatus[index] = obj.isSelected
        }
    }
    
    func setSelectCount(_ count: Int) {
        if count > maxSelectCount { return }
        selectedCount = count
        
        if let rightItem = self.navigationItem.rightBarButtonItem {
            rightItem.isEnabled = count > 0
            let string = "上传(\(count)/\(maxSelectCount))"
//            rightItem.title = string
            
            // 修复 设置item title 文字闪动bug
            let item = UIBarButtonItem(title: string, style: rightItem.style, target: self, action: #selector(newUploadAction(sender:)))
            item.isEnabled = rightItem.isEnabled
            item.tintColor = rightItem.tintColor
            self.navigationItem.rightBarButtonItem = item
        }
        
        self.collectionView?.reloadData()
    }
    
    @objc func newUploadAction(sender: UIBarButtonItem) {
        self.uploadAction(sender)
    }
    
    func updatePhotoListAlbum(_ obj: PhotoListAlbum?) {
        if let model = obj {
            currentPhotoListAlbum = model
            self.enumerateAssets(in: model.assetCollection)
            titleButton.setTitle(model.title, for: .normal)
        }
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - action

fileprivate extension PhotoAlbumViewController {
    
    @IBAction func cameraPickerAction(_ sender: UIButton) {
        if selectedCount >= maxSelectCount {
            SystemHelper.showTip("你最多只能选择\(maxSelectCount)张图片！")
            return
        }
        
        func showImagePickerVC() {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .camera
            imagePickerVC.allowsEditing = false
            imagePickerVC.delegate = self
            self.present(imagePickerVC, animated: true, completion: nil)
        }
        
        SystemHelper.verifyCameraAuthorization({ showImagePickerVC() })
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss()
    }
    
    @IBAction func selectPhotoAlbumAction(_ sender: RightImageButton) {
        self.changeButtonState(sender)
        if sender.isSelected {
            guard let albumList = currentPhotoListAlbum else { return }
            albumSelectView.show(atView: self.view,
                                 selectedAlbumList: albumList,
                                 block: { [weak self] (obj) in
                                            self?.changeButtonState(sender)
                                            self?.updatePhotoListAlbum(obj)
                                        })
        }
        else {
            albumSelectView.hide()
            self.changeButtonState(sender)
        }
    }
    
    func changeButtonState(_ sender: RightImageButton) {
        sender.isSelected = !sender.isSelected
        let hlImageName = sender.isSelected ? "jp_icon_upload_more_s" : "jp_icon_upload_more"
        sender.setImage(UIImage.my_bundleImage(named: hlImageName), for: .normal)
        sender.setImage(UIImage.my_bundleImage(named: hlImageName), for: .highlighted)
    }
    
    @IBAction func uploadAction(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        startUploadSelectPhoto()
    }
    
    func startUploadSelectPhoto() {
        var array: [JPhoto] = []
        for obj in self._uploadItems {
            guard let obj = obj as? PhotoAlbum else { break }
            if obj.isEdited {
                if let data = obj.editedImageData { array.append(JPhoto(data)) }
            }
            else {
                array.append(JPhoto(obj.asset))
            }
        }
        self.resultClosure?(array)
        self.dismiss()
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension PhotoAlbumViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                resultClosure?([JPhoto(imageData)])
            }
        }
        else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                resultClosure?([JPhoto(imageData)])
            }
        }
        else {
            print("Something went wrong")
        }
        
        picker.dismiss(animated: false) { 
            self.dismiss()
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - JHPhotoBrowserDelegate

extension PhotoAlbumViewController: JHPhotoBrowserDelegate {
    
    public func photoBrowserDidFinish(_ photoBrowser: PhotoBrowser) {
        if selectedCount == 0 {
            SystemHelper.showTip("你还没有选择图片哟！")
            return
        }
        
        startUploadSelectPhoto()
    }
    
    public func numberOfPhotosInPhotoBrowser(_ photoBrowser: PhotoBrowser) -> Int {
        return browserPhotos.count
    }
    
    public func photoBrowser(_ photoBrowser: PhotoBrowser, photoAtIndex: Int) -> Photo? {
        if photoAtIndex < browserPhotos.count {
            return browserPhotos[photoAtIndex]
        }
        return nil
    }
    
    public func photoBrowser(_ photoBrowser: PhotoBrowser, isPhotoSelectedAtIndex: Int) -> Bool {
        return selectedPhotoStatus[isPhotoSelectedAtIndex]
    }
    
    public func photoBrowser(_ photoBrowser: PhotoBrowser, photoAtIndex: Int, selectedChanged: Bool) -> Bool {

        if selectedChanged && selectedCount >= maxSelectCount {
            SystemHelper.showTip("你最多只能选择\(maxSelectCount)张图片！")
            return false
        }
        
        let model = albumList[photoAtIndex]
        model.isSelected = selectedChanged
        self.addUploadItem(model)
        print("Photo at index \(photoAtIndex) selected \(selectedChanged ? "YES" : "NO")")
        return true
    }
    
    public func photoBrowserDidEdit(_ photoBrowser: PhotoBrowser, photoAtIndex: Int) {
        let photo = browserPhotos[photoAtIndex]
        let album = albumList[photoAtIndex]
        
        if let image = photo.underlyingImage {
            if let imageData = image.jpegData(compressionQuality: 1), let albumData = image.jpegData(compressionQuality: 0.01) {
                album.isEdited = true
                album.editedImageData = imageData
                album.editedThumbImageData = albumData
                
                let indexPath = IndexPath(item: photoAtIndex, section: 0)
                if let cell = collectionView?.cellForItem(at: indexPath) as? PhotoAlbumCell {
                    cell.updatePhotoAlbum()
                }
            }
        }
    }
}
