//
//  PhotoBrowser.swift
//  JHPhotos
//
//  Created by winter on 2017/6/23.
//  Copyright © 2017年 DJ. All rights reserved.
//

import UIKit
import Kingfisher

public final class PhotoBrowser: UIViewController {
    
    fileprivate let padding: CGFloat = 10

    // MARK: - property
    fileprivate weak var delegate: JHPhotoBrowserDelegate?

    var isZoomPhotosToFill: Bool = true // display Photo zoom to fill
    var isDisplaySelectionButton: Bool = false 
    var isEnableSwipeToDismiss: Bool = true // 向上/下轻扫 退出
    var isAlwaysShowControls: Bool = false // 总是显示导航栏和工具栏
    var isSingleTapToHideNavbar = true // 单击隐藏/显示导航栏
    var isCanEditPhoto = false // 是否可以编辑当前图片（是否显示编辑按钮）
    var isShowDeleteBtn = false  // （是否显示删除图片按钮）
    var canSavePhoto = true   //是否支持保存图片至相册
    
    // Data
    fileprivate var photoCount: Int = NSNotFound
    fileprivate var photos = [AnyObject?]() // Photo/NSNull
    fileprivate var thumbPhotos = [AnyObject?]()
    
    // Views
    fileprivate lazy var pagingScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.isPagingEnabled = true;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.backgroundColor = UIColor.black;
        return scrollView
    }()
    
    // Paging & layout
    fileprivate var visiblePages = NSMutableOrderedSet() // [ZoomingScrollView]
    fileprivate var recycledPages = NSMutableOrderedSet() // [ZoomingScrollView]
    fileprivate var currentPageIndex: Int = 0
    fileprivate var previousPageIndex: Int = LONG_MAX
    fileprivate var previousLayoutBounds = CGRect.zero
    fileprivate var pageIndexBeforeRotation: Int = 0
    
    // Navigation & controls
    fileprivate lazy var toolbar: UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect.zero)
        toolBar.tintColor = UIColor.white
        toolBar.barTintColor = nil
        toolBar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        toolBar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .compactPrompt)
        toolBar.barStyle = .blackTranslucent
        toolBar.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        return toolBar
    }()
    
    // Customise image selection icons as they are the only icons with a colour tint
    // Icon should be located in the app's main bundle
    // var customImageSelectedIconName: String?
    
    fileprivate let arrowPathFormat: String = "jp_icon_itemArrow_"
    fileprivate let selectedIconName: String = "jp_icon_imageSelected_"
    
    var delayToHideElements: TimeInterval = 5
    fileprivate var controlVisibilityTimer: Timer!
    
    fileprivate var cancelButton: UIBarButtonItem!
    fileprivate var deleteButton: UIBarButtonItem!
    fileprivate lazy var selectedButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    fileprivate var editButton: UIBarButtonItem!
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate lazy var saveButton: UIButton = {
        let button = UIButton(type: .custom)
//        button.setImage(nil, for: .normal)
        button.addTarget(self, action: #selector(saveButtonPress), for: .touchUpInside)
        return button
    }()
    
    // Appearance
    fileprivate var isPreviousNavBarHidden: Bool = false
    fileprivate var isPreviousNavBarTranslucent: Bool = false
    fileprivate var previousNavBarStyle = UIBarStyle.default
    fileprivate var previousStatusBarStyle = UIStatusBarStyle.default
    fileprivate var previousNavBarTintColor: UIColor?
    fileprivate var previousNavBarBarTintColor: UIColor?
    fileprivate var previousViewControllerBackButton: UIBarButtonItem?
    fileprivate var previousNavigationBarBackgroundImageDefault: UIImage?
    fileprivate var previousNavigationBarBackgroundImageLandscapePhone: UIImage?
    fileprivate var previousNavBarBarTitleAttributes: [NSAttributedString.Key : Any]?
    
    // ActivityIndicator
    fileprivate var activityIndicator: UIActivityIndicatorView?
    
    // Misc
    fileprivate var isHasBelongedToViewController: Bool = false
    fileprivate var isVCBasedStatusBarAppearance: Bool = false
    fileprivate var isStatusBarShouldBeHidden: Bool = false
    fileprivate var isLeaveStatusBarAlone: Bool = false
    fileprivate var isPerformingLayout: Bool = false
    fileprivate var isRotating: Bool = false
    fileprivate var isViewIsActive: Bool = false
    
    // active as in it's in the view heirarchy
    fileprivate var isDidSavePreviousStateOfNavBar: Bool = false
    fileprivate var isSkipNextPagingScrollViewPositioning: Bool = false
    fileprivate var isViewHasAppearedInitially: Bool = false
    
    deinit {
        pagingScrollView.delegate = nil
        NotificationCenter.default.removeObserver(self)
        self.releaseAllUnderlyingPhotos(false)
        KingfisherManager.shared.cache.clearMemoryCache()
        
        print("PhotoBrowser deinit")
    }
    
    fileprivate func releaseAllUnderlyingPhotos(_ preserveCurrent: Bool) {
        // release photots
        for photo in photos {
            let photo = photo as AnyObject
            if !photo.isEqual(NSNull())  {
                if preserveCurrent && photo.isEqual(self.photo(atIndex: self.currentPageIndex)) {
                    continue // skip current
                }
                if let p = photo as? Photo {
                    p.unloadUnderlyingImage()
                }
            }
        }
        
        // release thumbs
        for photo in thumbPhotos {
            let photo = photo as AnyObject
            if !photo.isEqual(NSNull()) {
                let p = photo as! Photo
                p.unloadUnderlyingImage()
            }
        }
    }
    
    override public func didReceiveMemoryWarning() {
        self.releaseAllUnderlyingPhotos(true)
        recycledPages.removeAllObjects()
        super.didReceiveMemoryWarning()
    }
    
    public init(delgegate del: JHPhotoBrowserDelegate? = nil) {
        self.delegate = del
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _initialisation() {
        // default 
        if let isVCBasedStatusBarAppearanceNum = Bundle.main.object(forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance") {
            let num  = isVCBasedStatusBarAppearanceNum as! NSNumber
            isVCBasedStatusBarAppearance = num.boolValue
        }
        else {
            isVCBasedStatusBarAppearance = true // default
        }
        self.hidesBottomBarWhenPushed = true
    }
    
    // MARK: - View Loading

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self._initialisation()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePhotoLoadingDidEndNotification(notification:)),
                                               name: PHOTO_LOADING_DID_END_NOTIFICATION,
                                               object: nil)
        
        pagingScrollView.delegate = self
        pagingScrollView.frame = self.frameForPagingScrollView()
        pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
        self.view.addSubview(pagingScrollView)
        
        toolbar.frame = self.frameForToolbar(.portrait)
        
        if isDisplaySelectionButton {
            
            let selectedIconNameONImage = UIImage.my_bundleImage(named: selectedIconName + "ON")
            let selectedIconNameOFFImage = UIImage.my_bundleImage(named: selectedIconName + "OFF")
            selectedButton.setImage(selectedIconNameONImage, for: .selected)
            selectedButton.setImage(selectedIconNameOFFImage, for: .normal)
            selectedButton.sizeToFit()
            selectedButton.adjustsImageWhenHighlighted = false
            selectedButton.addTarget(self, action: #selector(selectedButtonTapped(sender:)), for: .touchUpInside)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: selectedButton)

        }
        
        if isEnableSwipeToDismiss {
            let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector(dismissButtonPressed(_:)))
            swipe.direction = [.down, .up]
            self.view.addGestureRecognizer(swipe)
        }
        
        if isCanEditPhoto {
            editButton = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(gotoEditImage))
        }
        
        if isDisplaySelectionButton {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            button.backgroundColor = UIColor(red:0.07,green:0.39,blue:0.85,alpha:1.00)
            button.layer.cornerRadius = 4
            button.setTitle("完成", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(UIColor.white, for: .normal)
            button.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
            doneButton = UIBarButtonItem(customView: button)
        }
        
        if canSavePhoto {
            view.addSubview(saveButton)
        }
        
        self.reloadData()
    }
    
    private func performLayout() {
        // setup
        isPerformingLayout = true
        
        visiblePages.removeAllObjects()
        recycledPages.removeAllObjects()
        
        // navigation buttons
        if let vc = self.navigationController?.viewControllers.first, vc.isEqual(self) {
//            cancelButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(dismissButtonPressed(_:)))
            let image = UIImage(named: "jp_icon_nav_back")
            cancelButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(dismissButtonPressed(_:)))
//            cancelButton.setBackgroundImage(nil, for: .normal, barMetrics: .default)
//            cancelButton.setBackgroundImage(nil, for: .normal, barMetrics: .compactPrompt)
//            cancelButton.setBackgroundImage(nil, for: .highlighted, barMetrics: .default)
//            cancelButton.setBackgroundImage(nil, for: .highlighted, barMetrics: .compactPrompt)
//            cancelButton.setTitleTextAttributes(nil, for: .normal)
//            cancelButton.setTitleTextAttributes(nil, for: .highlighted)
            
            self.navigationItem.leftBarButtonItem = cancelButton
            
            if isShowDeleteBtn { //添加删除按钮
                let btn = UIButton(type: .custom)
                btn.setImage(UIImage(named: "icon_trash_delete"), for: .normal)
                btn.addTarget(self, action: #selector(deleteButtonPress), for: .touchUpInside)
                deleteButton = UIBarButtonItem(customView: btn)
                self.navigationItem.rightBarButtonItem = deleteButton
            }
        }
        else {
            if let vcs = self.navigationController?.viewControllers {
                let previousVC = vcs[vcs.count - 2]
                
                previousViewControllerBackButton = previousVC.navigationItem.backBarButtonItem; // remember previous
                
                let newBackButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(dismissButtonPressed(_:)))
                newBackButton.setBackgroundImage(nil, for: .normal, barMetrics: .default)
                newBackButton.setBackgroundImage(nil, for: .normal, barMetrics: .compactPrompt)
                newBackButton.setBackgroundImage(nil, for: .highlighted, barMetrics: .default)
                newBackButton.setBackgroundImage(nil, for: .highlighted, barMetrics: .compactPrompt)
                newBackButton.setTitleTextAttributes(nil, for: .normal)
                newBackButton.setTitleTextAttributes(nil, for: .highlighted)
                previousVC.navigationItem.backBarButtonItem = newBackButton
            }
        }
        
        // toolbar items
        let flexSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        var items: [UIBarButtonItem] = []
        
        
        if isCanEditPhoto {
            items.append(flexSpace)
            items.insert(editButton, at: 0)
//            items.append(doneButton)
        }
        else if isDisplaySelectionButton {
            items.insert(flexSpace, at: 0)
            items.append(doneButton)
        }
        
        // toolbar visibility
        toolbar.items = items
        var hideToolbar = true
        for item in toolbar.items! {
            if !item.isEqual(flexSpace) {
                hideToolbar = false
                break
            }
        }
        if hideToolbar {
            toolbar.removeFromSuperview()
        }
        else {
            self.view.addSubview(toolbar)
        }
        
        // update nav
        self.updateNavigationAndTool()
        
        // content offset
        pagingScrollView.contentOffset = self.contentOffsetForPage(currentPageIndex)
        self.tilePages()
        isPerformingLayout = false
    }
    
    private func presentingViewControllerPrefersStatusBarHidden() -> Bool {
        let presenting = self.presentingViewController
        if let nav = presenting as? UINavigationController {
            if let p = nav.topViewController {
                return p.prefersStatusBarHidden
            }
        }
        else {
            // We're in a navigation controller so get previous one!
            if let nav = self.navigationController {
                if nav.viewControllers.count > 1 {
                    let p = nav.viewControllers[nav.viewControllers.count - 2] as UIViewController
                    return p.prefersStatusBarHidden
                }
            }
        }
        return false
    }

    // MARK: - Appearance
    
    override public var prefersStatusBarHidden: Bool {
        if !isLeaveStatusBarAlone {
            return isStatusBarShouldBeHidden
        }
        else {
            return self.presentingViewControllerPrefersStatusBarHidden()
        }
    }
    
    override public var preferredStatusBarStyle : UIStatusBarStyle {
        if !isLeaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == .phone {
            return previousStatusBarStyle
        }
        return UIStatusBarStyle.lightContent
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // status bar
        if !isViewHasAppearedInitially {
            isLeaveStatusBarAlone = self.presentingViewControllerPrefersStatusBarHidden()
            // check is status abr is hidden on first appear, and if so then ignore it
            if UIApplication.shared.statusBarFrame.equalTo(CGRect.zero) {
                isLeaveStatusBarAlone = true
            }
        }
        
        // set style
        if !isLeaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == .phone {
            previousStatusBarStyle = UIApplication.shared.statusBarStyle
        }
        
        // Navigation bar appearance
        if !isViewIsActive && !(self.navigationController?.viewControllers[0].isEqual(self))! {
            self.storePreviousNavBarAppearance()
        }
        self.setNavBarAppearance(animated)
        
        // update UI
        if !isSingleTapToHideNavbar {
            // 添加 单击 才会隐藏导航栏而不是自动隐藏
            self.hideControlsAfterDelay()
        }
    
        // If rotation occured while we're presenting a modal
        // and the index changed, make sure we show the right one now
        if currentPageIndex != pageIndexBeforeRotation {
            self.jumpToPage(currentPageIndex, animated: false)
        }
        
        self.view.setNeedsLayout()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewIsActive = true
        isViewHasAppearedInitially = true
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        // Detect if rotation occurs while we're presenting a modal
        pageIndexBeforeRotation = currentPageIndex
        
        // Check that we're disappearing for good
        // self.isMovingFromParentViewController just doesn't work, ever. Or self.isBeingDismissed
        if (cancelButton != nil && (self.navigationController?.isBeingDismissed)!) ||
            (self.navigationController?.viewControllers[0] != self && !(self.navigationController?.viewControllers.contains(self))!) {
            // state
            isViewIsActive = false
            
            // bar state / appearance
            self.restorePreviousNavBarAppearance(animated)
        }
        
        // controls
        self.navigationController?.navigationBar.layer.removeAllAnimations() // stop all animations on nav bar
        NSObject.cancelPreviousPerformRequests(withTarget: self) // cancel any pending toggles from taps
        self.setControls(hidden: false, animated: false, permanent: true)
        
        super.viewWillDisappear(animated)
    }
    
    override public func willMove(toParent parent: UIViewController?) {
        if parent != nil && isHasBelongedToViewController {
            let e = NSException(name:NSExceptionName(rawValue: "PhotoBrowser Instance Reuse"),
                                reason:"PhotoBrowser instances cannot be reused.",
                                userInfo:nil)
            e.raise()
        }
    }
    
    override public func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            isHasBelongedToViewController = true
        }
    }

    // MARK: - Layout
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutVisiblePages()
    }
    
    private func layoutVisiblePages() {
        // flag 
        isPerformingLayout = true
        
        // toolbar
        toolbar.frame = self.frameForToolbar(.portrait)
        
        if canSavePhoto {
            saveButton.frame = frameForSaveButton(.portrait)
        }
        
        // remember index
        let indexPriorToLayout = currentPageIndex
        
        // get paging scroll view frame to determine if anything needs chaning
        let pagingScrollViewFrame = self.frameForPagingScrollView()
        
        // frame needs changing
        if !isSkipNextPagingScrollViewPositioning {
            pagingScrollView.frame = pagingScrollViewFrame
        }
        isSkipNextPagingScrollViewPositioning = false
        
        // recalculate contentSize based on current orientation
        pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
        
        // adjust frames and configuration of each visible page
        for p in visiblePages {
            let page = p as! ZoomingScrollView
            let idx = page.index
            page.frame = self.frameForPage(atIndex: idx)
            
            // adjust scales if bounds has changed since last time
            if !previousLayoutBounds.equalTo(self.view.bounds) {
                // update zooms for new bounds
                page.setMaxMinZoomScalesForCurrentBounds()
                previousLayoutBounds = self.view.bounds
            }
        }
        
        // reset
        currentPageIndex = indexPriorToLayout
        isPerformingLayout = false
    }
    
    // MARK: - Properties
    
    private func willSetCurrentPageIndex(_ index: Int) -> Int {
        // Validate
        let count = self.numberOfPhotos()
        if count == 0 { return 0 }
        if index >= count {
            return count - 1
        }
        else {
            return index
        }
    }
    
    // first show index
    public func setCurrentPageIndex(_ index: Int) {
        currentPageIndex = self.willSetCurrentPageIndex(index)
        if self.isViewLoaded {
            self.jumpToPage(currentPageIndex, animated: false)
            if !isViewIsActive {
                // Force tiling if view is not visible
                self.tilePages()
            }
        }
    }

    // MARK: - data
    
    // Reloads the photo browser and refetches data
    public func reloadData() {
        // reset
        photoCount = NSNotFound
        
        // get data
        let num: Int = self.numberOfPhotos()
        self.releaseAllUnderlyingPhotos(true)
        photos.removeAll()
        thumbPhotos.removeAll()
        for _ in 0 ..< num {
            photos.append(NSNull())
            thumbPhotos.append(NSNull())
        }
        
        // Update current page index
        if num > 0 {
            currentPageIndex = max(0, min(currentPageIndex, num - 1))
        }
        else {
            currentPageIndex = 0
        }
        
        // update layout
        if self.isViewLoaded {
            while pagingScrollView.subviews.count > 0 {
                if let view = pagingScrollView.subviews.last {
                    view.removeFromSuperview()
                }
            }
            self.performLayout()
            self.view.setNeedsLayout()
        }
    }
    
    fileprivate func numberOfPhotos() -> Int {
        if let count = delegate?.numberOfPhotosInPhotoBrowser(self) {
            photoCount = count
        }
        return photoCount
    }
    
    fileprivate func photo(atIndex index: Int) -> Photo? {
        var photo: Photo?
        if index < photos.count {
            if let tempPhoto = photos[index] {
                if tempPhoto.isEqual(NSNull()) {
                    if let p = delegate?.photoBrowser(self, photoAtIndex: index) {
                        photo = p
                        photos[index] = p
                    }
                }
                else {
                    photo = tempPhoto as? Photo
                }
            }
        }
        return photo
    }

    fileprivate func thumbPhoto(atIndex index: Int) -> Photo? {
        var photo: Photo?
        if index < thumbPhotos.count {
            if let p = thumbPhotos[index], p.isEqual(NSNull()) {
                if let p = delegate?.photoBrowser(self, thumbPhotoAtIndex: index) {
                    photo = p
                    thumbPhotos[index] = photo
                }
            }
            else {
                photo = thumbPhotos[index] as? Photo
            }
        }
        return photo
    }

    fileprivate func  photoIsSelected(atIndex index: Int) -> Bool {
        var value = false
        if isDisplaySelectionButton {
            if let b = delegate?.photoBrowser(self, isPhotoSelectedAtIndex: index) {
                value = b
            }
        }
        return value
    }
    
    fileprivate func  setPhotoSelected(_ selected: Bool, index: Int) {
        if isDisplaySelectionButton {
            if let result = self.delegate?.photoBrowser(self, photoAtIndex: index, selectedChanged: selected) {
                if !result {
                    selectedButton.isSelected = !selectedButton.isSelected
                }
            }
        }
    }
    
    func imageForPhoto(_ photo: Any?) -> UIImage? {
        let photo = photo as? Photo
        if let p = photo {
            if let image = p.underlyingImage {
                return image
            }
            else {
                p.loadUnderlyingImageAndNotify()
                return nil
            }
        }
        return nil
    }
    
    fileprivate func  loadAdjacentPhotosIfNecessary(_ photo: Photo!) {
        if let page = self.pageDisplaying(photo) {
            // If page is current page then initiate loading of previous and next pages
            let pageIndex = page.index
            if currentPageIndex == pageIndex {
                if pageIndex > 0 {
                    // preload index-1
                    if let p = self.photo(atIndex: pageIndex - 1), (p.underlyingImage == nil) {
                        p.loadUnderlyingImageAndNotify()
//                        print("Pre-loading image at index \(pageIndex - 1)")
                    }
                }
                if pageIndex < (self.numberOfPhotos() - 1) {
                    // preload index+1
                    if let p = self.photo(atIndex: pageIndex + 1), (p.underlyingImage == nil) {
                        p.loadUnderlyingImageAndNotify()
//                        print("Pre-loading image at index \(pageIndex + 1)")
                    }
                }
            }
        }
    }
    
    // MARK: - Photo Loading Notification
    
    @objc fileprivate func handlePhotoLoadingDidEndNotification(notification: NSNotification) {
        let photo = notification.object as! Photo
        let page = self.pageDisplaying(photo)
        if page != nil  {
            if photo.underlyingImage != nil {
                // successful load
                page?.displayImage()
                self.loadAdjacentPhotosIfNecessary(photo)
            }
            else {
                // failed to load
                page?.displayImageFailure()
            }
            // update nav
            self.updateNavigationAndTool()
        }
    }
    
    // MARK: - navigation

    func  updateNavigationAndTool() {
        let numberOfPhotos = self.numberOfPhotos()
        // Title
        if numberOfPhotos > 1 {
            if let title = self.delegate?.photoBrowser(self, titleForPhotoAtIndex: currentPageIndex) {
                self.title = title
            }
            else {
                self.title = "\(currentPageIndex+1)/\(numberOfPhotos)"
            }
        }
        else { self.title = "" }
    }
    
    func  jumpToPage(_ index: Int, animated: Bool) {
        // change page
        if index < self.numberOfPhotos() {
            let pageFrame = self.frameForPage(atIndex: index)
            pagingScrollView.setContentOffset(CGPoint(x: pageFrame.minX - padding, y: 0), animated: animated)
            self.updateNavigationAndTool()
        }
        // update timer to give more time
        if !isSingleTapToHideNavbar {
            // 不能单击隐藏时，自动隐藏
            self.hideControlsAfterDelay()
        }
    }
    
    @objc fileprivate func gotoPreviousPage() {
        self.showPreviousPhoto(false)
    }
    
    @objc fileprivate func gotoNextPage() {
        self.showNextPhoto(false)
    }
    
    @objc fileprivate func gotoEditImage() {
//        if let currentPhoto = photo(atIndex: currentPageIndex), let image = currentPhoto.underlyingImage {
//            let cropController = CropViewController(image: image, delegate: self)
//            if let pageView = visiblePages.lastObject as? ZoomingScrollView {
//                let imageView = pageView.imageView()
//                let viewFrame = view.convert(imageView.frame, to: navigationController?.view)
//
//                cropController.presentAnimated(fromParentViewController: self,
//                                               fromView: imageView,
//                                               fromFrame: viewFrame,
//                                               setup: nil, completion: nil)
//            }
//        }
    }
    
    @objc fileprivate func doneButtonAction() {
        delegate?.photoBrowserDidFinish(self)
    }
    
    fileprivate func  showPreviousPhoto(_ animated: Bool) {
        self.jumpToPage(currentPageIndex - 1, animated: animated);
    }
    
    fileprivate func  showNextPhoto(_ animated: Bool) {
        self.jumpToPage(currentPageIndex + 1, animated: animated)
    }
    
    // MARK: - Interactions
    
    @objc fileprivate func selectedButtonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var index = LONG_MAX
        for p in visiblePages {
            let page = p as! ZoomingScrollView
            if let button = page.selectedButton, button.isEqual(sender) {
                index = page.index
                break
            }
        }
        if index != LONG_MAX {
            self.setPhotoSelected(sender.isSelected, index: index)
        }
    }
    
    // MARK: - Actions
    @objc fileprivate func dismissButtonPressed(_ sender: Any) {
        // Only if we're modal and there's a done button
        if cancelButton != nil {
            // dismiss view controller
//            delegate?.photoBrowserDidFinishModalPresentation!(self)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func actionButtonPressed(sender: Any) {
        // Only react when image has loaded
        if let photo = self.photo(atIndex: currentPageIndex) {
            if self.numberOfPhotos() > 0 && photo.underlyingImage != nil {
                // If they have defined a delegate method then just message them
                delegate?.photoBrowser(self, actionButtonPressedForPhotoAtIndex: currentPageIndex)
            }
        }
    }
    
    @objc fileprivate func deleteButtonPress() {
        // 删除预览数组中该图片
        photos.remove(at: currentPageIndex)
        delegate?.photoBrowserDeleteImage(self , photoAtIndex: currentPageIndex)
        if photos.count == 0 {
            self.dismiss(animated: true, completion: nil)
        }else {
            reloadData()
            updateNavigationAndTool()
        }
    }
    
    @objc fileprivate func saveButtonPress() {
        savePhoto()
    }
}

// MARK: - CropViewControllerDelegate

//extension PhotoBrowser: CropViewControllerDelegate {
//
//    public func cropViewController(_ cropViewController: CropViewController, didCropToImage: UIImage, rect: CGRect, angle: Int) -> Bool {
//
//        if let currentPhoto = photo(atIndex: currentPageIndex) {
//
//            // 更新编辑之后的图片
//            currentPhoto.updateCurrentImage(didCropToImage)
//            delegate?.photoBrowserDidEdit(self, photoAtIndex: currentPageIndex)
//
//            // 编辑后的图片 选中
//            selectedButton.isSelected = true
//            setPhotoSelected(true, index: currentPageIndex)
//
//            if let pageView = visiblePages.lastObject as? ZoomingScrollView {
//                pageView.updateImage(didCropToImage)
//                let imageView = pageView.imageView()
//                let viewFrame = view.convert(imageView.frame, to: navigationController?.view)
//
//                cropViewController.dismissAnimated(fromParentViewController: self,
//                                                   toView: imageView,
//                                                   toFrame: viewFrame,
//                                                   setup: nil,
//                                                   completion: nil)
//            }
//        }
//        return true
//    }
//
//    public func cropViewController(_ cropViewController: CropViewController, didCancelled: Bool) -> Bool {
//        if let pageView = visiblePages.lastObject as? ZoomingScrollView {
//            let imageView = pageView.imageView()
//            let viewFrame = view.convert(imageView.frame, to: navigationController?.view)
//
//            cropViewController.dismissAnimated(fromParentViewController: self,
//                                               toView: imageView,
//                                               toFrame: viewFrame,
//                                               setup: nil,
//                                               completion: nil)
//        }
//        return true
//    }
//}

// MARK: - control

extension PhotoBrowser {
    
    func setControls(hidden: Bool, animated: Bool, permanent: Bool) {
        // Force visible
        var hidden = hidden
        if self.numberOfPhotos() == 0 || isAlwaysShowControls || !isSingleTapToHideNavbar {
            hidden = false
        }
        
        let permanent = isSingleTapToHideNavbar
        
        // cancel any timers
        self.cancelControlHiding()
        
        // animation & positions
        let animationOffset: CGFloat = 20
        let animationDuration: TimeInterval = animated ? 0.35 : 0
        
        // status bar
        if !isLeaveStatusBarAlone {
            // hide status bar
            if !isVCBasedStatusBarAppearance {
                // non-view controller based
                isStatusBarShouldBeHidden = hidden
                self.setNeedsStatusBarAppearanceUpdate()
            }
            else {
                // view controller based so animated away
                isStatusBarShouldBeHidden = hidden
                UIView.animate(withDuration: animationDuration, animations: { 
                    self.setNeedsStatusBarAppearanceUpdate()
                })
            }
        }
        
        // toolbar, nav
        if self.areControlsHidden() && !hidden && animated {
            toolbar.frame = self.frameForToolbar(.portrait).offsetBy(dx: 0, dy: animationOffset)
        }
        
        let alpha: CGFloat = hidden ? 0 : 1;
        let toolbarFrame = self.frameForToolbar(.portrait)
        
        UIView.animate(withDuration: animationDuration, animations: { 
            self.navigationController?.navigationBar.alpha = alpha
            self.toolbar.frame = toolbarFrame
            if hidden {
                self.toolbar.frame = toolbarFrame.offsetBy(dx: 0, dy: animationOffset)
            }
            self.toolbar.alpha = alpha
        }) { (finished) in
            // Control hiding timer
            // Will cancel existing timer but only begin hiding if
            // they are visible
            if !permanent {
                self.hideControlsAfterDelay()
            }
        }
    }
    
    func cancelControlHiding() {
        // if a timer exists then cancel and release
        if controlVisibilityTimer != nil {
            controlVisibilityTimer.invalidate()
            controlVisibilityTimer = nil
        }
    }
    
    func hideControlsAfterDelay() {
        // enable/disable control visiblety timer
        if !self.areControlsHidden() {
            self.cancelControlHiding()
            controlVisibilityTimer = Timer.scheduledTimer(timeInterval: delayToHideElements, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
        }
    }
    
    func controlAllAontrols() {
        let delaySeconds: TimeInterval = 0.2
        let delayTime = DispatchTime.now() + delaySeconds
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.toggleControls()
        }
    }
    
    func areControlsHidden() -> Bool {
        return toolbar.alpha <= 0.0
    }
    
    @objc fileprivate func hideControls() {
        self.setControls(hidden: true, animated: true, permanent: false)
    }
    
    fileprivate func showControls() {
        self.setControls(hidden: false, animated: true, permanent: false)
    }
    
    fileprivate func toggleControls() {
        self.setControls(hidden: !self.areControlsHidden(), animated: true, permanent: false)
    }
}

// MARK: - paging

fileprivate extension PhotoBrowser {
    func tilePages() {
        // Calculate which pages should be visible
        // Ignore padding as paging bounces encroach on that
        // and lead to false page loads
        let numOfPhotos = self.numberOfPhotos()
        let visibleBounds = pagingScrollView.bounds
        var iFirstIndex = Int((visibleBounds.minX + padding * 2) / visibleBounds.width)
        var iLastIndex = Int((visibleBounds.maxX - padding * 2 - 1) / visibleBounds.width)
        if iFirstIndex < 0 {
            iFirstIndex = 0
        }
        if iFirstIndex > (numOfPhotos - 1) {
            iFirstIndex = numOfPhotos - 1
        }
        if iLastIndex < 0 {
            iLastIndex = 0
        }
        if iLastIndex > (numOfPhotos - 1) {
            iLastIndex = numOfPhotos - 1
        }
        
        // Recycle no longer needed pages
        var pageIndex = 0
        for p in visiblePages {
            let page = p as! ZoomingScrollView
            pageIndex = page.index
            if pageIndex < iFirstIndex || pageIndex > iLastIndex {
                recycledPages.add(page)
                page.prepareForReuse()
                page.removeFromSuperview()
//                print("Removed page at index \(pageIndex)")
            }
        }
        visiblePages.minus(recycledPages)
        while recycledPages.count > 2 {
            // Only keep 2 recycled pages
            recycledPages.removeObject(at: 0)
        }
        
        if iFirstIndex == iLastIndex {
            // if stay put
            // recover selected button
            if isDisplaySelectionButton {
                if let page = self.dequeueRecycledPage() {
                    page.selectedButton = selectedButton
                    selectedButton.isSelected = photoIsSelected(atIndex: iLastIndex)
                }
            }
        }
        
        // add missing pages
        for index in iFirstIndex...iLastIndex {
            if !self.isDisplayingPage(forIndex: index) {
                // add new page
                var page = self.dequeueRecycledPage()
                if page == nil {
                    page = ZoomingScrollView.init(self)
                }
                page = page!
                visiblePages.add(page!)
                self.configurePage(page, index: index)
                pagingScrollView.addSubview(page!)
//                print("Added page at index \(index)")
                
                // Add selected button
                if isDisplaySelectionButton {
                    page!.selectedButton = selectedButton
                    selectedButton.isSelected = self.photoIsSelected(atIndex: index)
                }
            }
        }
    }
    
    func isDisplayingPage(forIndex index: Int) -> Bool {
        for page in visiblePages {
            let page = page as! ZoomingScrollView
            if index == page.index {
                return true
            }
        }
        return false
    }
    
    func pageDisplaying(_ photo: Photo) -> ZoomingScrollView? {
        for page in visiblePages {
            let page = page as! ZoomingScrollView
            if photo == page.photo {
                return page
            }
        }
        return nil
    }
    
    func pageDisplayed(_ index: Int) -> ZoomingScrollView? {
        for page in visiblePages {
            let page = page as! ZoomingScrollView
            if index == page.index {
                return page
            }
        }
        return nil
    }
    
    func configurePage(_ page: ZoomingScrollView!, index: Int) {
        page.frame = self.frameForPage(atIndex: index)
        page.contentSize = page.frame.size
        page.index = index
        page.photo = self.photo(atIndex: index)
    }
    
    func dequeueRecycledPage() -> ZoomingScrollView? {
        if let page = recycledPages.firstObject {
            recycledPages.remove(page)
            return page as? ZoomingScrollView
        }
        return nil
    }
    
    // Handle page changes
    func didStartViewingPage(atIndex index: Int) {
        let photosNumber = self.numberOfPhotos()
        // handle 0 photos
        if photosNumber == 0 {
            self.setControls(hidden: false, animated: true, permanent: true)
            return
        }
        
        // release images further away than +/-1
        if index > 0 {
            // release anything < index - 1
            for i in 0 ..< index - 1 {
                let photo = photos[i]
                if let p = photo as? Photo {
                    p.unloadUnderlyingImage()
                    photos[i] = NSNull()
//                    print("Released underlying image at index \(i)")
                }
            }
        }
        
        if index < photosNumber - 1 {
            // Release anything > index + 1
            for i in index + 2 ..< photos.count {
                let photo = photos[i]
                if let p = photo as? Photo {
                    p.unloadUnderlyingImage()
                    photos[i] = NSNull()
//                    print("Released underlying image at index \(i)")
                }
            }
        }
        
        // Load adjacent images if needed and the photo is already
        // loaded. Also called after photo has been loaded in background
        if let currentPhoto = self.photo(atIndex: index), currentPhoto.underlyingImage != nil {
            // photo loaded so load adjacent now
            self.loadAdjacentPhotosIfNecessary(currentPhoto)
        }
        
        // Notify delegate
        if index != previousPageIndex {
            self.delegate?.photoBrowser(self, didDisplayPhotoAtIndex: index)
            previousPageIndex = index
        }
        
        // update nav
        self.updateNavigationAndTool()
    }
}

// MARK: - Frame Calculations

fileprivate extension PhotoBrowser {
    func frameForPagingScrollView() -> CGRect {
        var frame = self.view.bounds // UIScreen.main.bounds
        frame.origin.x -= padding
        frame.size.width += (2 * padding)
        return frame.integral
    }
    
    func frameForPage(atIndex index: Int) -> CGRect {
        let bounds = pagingScrollView.bounds
        var pageFrame = bounds
        pageFrame.size.width -= (2 * padding)
        pageFrame.origin.x = (bounds.width * CGFloat(index)) + padding
        return pageFrame.integral
    }
    
    func contentSizeForPagingScrollView() -> CGSize {
        let bounds = pagingScrollView.bounds
        let i = self.numberOfPhotos()
        return CGSize(width: bounds.width * CGFloat(i), height: bounds.height)
    }
    
    func contentOffsetForPage(_ index: Int) -> CGPoint {
        let pageWidth = pagingScrollView.bounds.width
        let newOffset = CGFloat(index) * pageWidth
        return CGPoint(x: newOffset, y: 0)
    }
    
    func frameForToolbar(_ orientation: UIInterfaceOrientation) -> CGRect {
        var height: CGFloat = jp_bottomSpace + 44
        if UI_USER_INTERFACE_IDIOM() == .phone && orientation.isLandscape {
            height = 32
        }
        return CGRect(x: 0, y: self.view.bounds.height - height, width: self.view.bounds.width, height: height)
    }
    
    func frameForSaveButton(_ orientation: UIInterfaceOrientation) -> CGRect {
        var height: CGFloat = 40 + 36
        if UI_USER_INTERFACE_IDIOM() == .phone && orientation.isLandscape {
            height = 32
        }
        return CGRect(x: view.bounds.width - 56, y: view.bounds.height - height, width: 36, height: 36)
    }
}

// MARK: - Nav Bar Appearance
fileprivate extension PhotoBrowser {
    func setNavBarAppearance(_ animated: Bool) {
        if let navC = self.navigationController {
            navC.setNavigationBarHidden(false, animated: animated)
            let navBar = navC.navigationBar
            navBar.tintColor = UIColor.white
            navBar.barTintColor = nil
            navBar.shadowImage = nil
            navBar.isTranslucent = true
            navBar.barStyle = .blackTranslucent

            let color = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.9)
            let backgroundImage = UIImage.color(color)
            navBar.setBackgroundImage(backgroundImage, for: .default)
            navBar.setBackgroundImage(backgroundImage, for: .compactPrompt)
            
            let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navBar.titleTextAttributes = titleAttributes
        }
    }
    
    func storePreviousNavBarAppearance() {
        if let navC = self.navigationController {
            isDidSavePreviousStateOfNavBar = true
            isPreviousNavBarHidden = navC.isNavigationBarHidden
            let navBar = navC.navigationBar
            previousNavBarBarTintColor = navBar.barTintColor
            isPreviousNavBarTranslucent = navBar.isTranslucent
            previousNavBarTintColor = navBar.tintColor
            previousNavBarStyle = navBar.barStyle
            previousNavigationBarBackgroundImageDefault = navBar.backgroundImage(for: .default)
            previousNavigationBarBackgroundImageLandscapePhone = navBar.backgroundImage(for: .compactPrompt)
            previousNavBarBarTitleAttributes = navBar.titleTextAttributes
        }
    }
    
    func restorePreviousNavBarAppearance(_ animated: Bool) {
        if isDidSavePreviousStateOfNavBar, let navC = self.navigationController {
            navC.setNavigationBarHidden(isPreviousNavBarHidden, animated: animated)
            let navBar = navC.navigationBar
            navBar.tintColor = previousNavBarTintColor
            navBar.barTintColor = previousNavBarBarTintColor
            navBar.isTranslucent = isPreviousNavBarTranslucent
            navBar.barStyle = previousNavBarStyle
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageDefault, for: .default)
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageLandscapePhone, for: .compactPrompt)
            navBar.titleTextAttributes = previousNavBarBarTitleAttributes
            
            // Restore back button if we need to
            if previousViewControllerBackButton != nil {
                if let previousVC = navC.topViewController {
                    previousVC.navigationItem.backBarButtonItem = previousViewControllerBackButton
                    previousViewControllerBackButton = nil
                }
            }
        }
    }
}

// MARK: - ScrollViewDelegate

extension PhotoBrowser: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // checks
        if !isViewIsActive || isPerformingLayout || isRotating {
            return
        }
        
        self.tilePages()
        
        // calculate current page
        let visibleBounds = pagingScrollView.bounds
        var index = Int(visibleBounds.midX / visibleBounds.width)
        if index < 0 {
            index = 0
        }
        let num = self.numberOfPhotos()
        if index > (num - 1) {
            index = num - 1
        }
        let previousCurrentPage = currentPageIndex
        currentPageIndex = index
        if currentPageIndex != previousCurrentPage {
            self.didStartViewingPage(atIndex: index)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // hide controlls when dragging begins if 'SingleTapToHideNavbar == false'
        if !isSingleTapToHideNavbar {
            self.setControls(hidden: true, animated: true, permanent: false)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // update nav when page changes
        self.updateNavigationAndTool()
        self.tilePages()
    }
}

// MARK: - longPress & save image
extension PhotoBrowser {
    
    func longPressAction() {
        guard canSavePhoto else { return }
//        delegate?.photoBrowser(self, longPressAtIndex: currentPageIndex)
        
        let alert = SelectAlert()
        let cancel = SelectAlertAction(title: "取消", type: .cancel)
        let doit  = SelectAlertAction(title: "保存") { [weak self] in
            self?.savePhoto()
        }
        
        alert.addAction(cancel)
        alert.addAction(doit)
        alert.show()
    }
    
    func savePhoto() {
        
        let doit = { [weak self] in
            guard let `self` = self else { return }
            guard let currentPhoto = self.photo(atIndex: self.currentPageIndex),
                let image = currentPhoto.underlyingImage else { return }
            UIImageWriteToSavedPhotosAlbum(image, self,
                                           #selector(self.savedPhotosAlbum(_:_:_:)), nil)
        }
        
        SystemHelper.verifyPhotoLibraryAuthorization({ doit() })
    }
    
    @objc func savedPhotosAlbum(_ image: UIImage, _ error: NSError?, _ contextInfo: AnyObject) {
        if error != nil {
            EToast.showFailed("保存失败")
        } else {
            EToast.showSuccess("保存成功")
        }
    }

}
