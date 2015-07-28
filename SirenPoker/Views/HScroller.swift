//
//  HScroller.swift
//  StyleShare
//
//  Created by 전수열 on 2/17/15.
//  Copyright (c) 2015 StyleShare Inc. All rights reserved.
//

import UIKit

public class HScroller: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {

    private let CellIdentifier = "Cell"

    private var collectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout {
        return self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    private var registeredCellClass: AnyClass?
    private var touchUpGestureRecognizer: UITapGestureRecognizer!

    public weak var delegate: HScrollerDelegate?

    public var pagingEnabled: Bool = false {
        willSet {
            if !self.pagingEnabled && newValue {
                self.updateCurrentPage()
            }
        }
    }

    /// `true`일 경우 한 번의 스크롤로 여러 페이지를 넘길 수 있다.
    public var canScrollMultiplePages: Bool = false

    private var _currentPage: Int = 0
    public var currentPage: Int {
        get { return self._currentPage }
        set { self.setCurrentPage(newValue, animated: false) }
    }

    public var itemSize: CGSize {
        get { return self.layout.itemSize }
        set {
            if self.layout.itemSize != newValue {
                self.layout.itemSize = newValue
            }
        }
    }

    public var itemSpacing: CGFloat {
        get { return self.layout.minimumLineSpacing }
        set {
            if self.layout.minimumLineSpacing != newValue {
                self.layout.minimumLineSpacing = newValue
            }
        }
    }

    public var contentInset: CGFloat {
        get { return self.collectionView.contentInset.left }
        set {
            if self.collectionView.contentInset.left != newValue {
                self.collectionView.contentInset.left = newValue
            }
            if self.collectionView.contentInset.right != newValue {
                self.collectionView.contentInset.right = newValue
            }
        }
    }


    public convenience init() {
        self.init(frame: CGRectZero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal

        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.scrollsToTop = false
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.addSubview(self.collectionView)

        self.touchUpGestureRecognizer = UITapGestureRecognizer(target: self, action: "collectionViewDidTouchUp")
        self.touchUpGestureRecognizer.delegate = self
        self.touchUpGestureRecognizer.cancelsTouchesInView = false
        self.collectionView.addGestureRecognizer(self.touchUpGestureRecognizer)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        self.delegate = nil
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.collectionView.frame != self.bounds {
            self.collectionView.frame = self.bounds
        }
    }


    // MARK: - Public Interfaace

    public func registerClass(cellClass: AnyClass) {
        self.registeredCellClass = cellClass
        self.collectionView.registerClass(cellClass, forCellWithReuseIdentifier: CellIdentifier)
    }

    public func reloadData() {
        self.collectionView.reloadData()
    }

    public func insertItemsAtIndexes(indexes: [Int]) {
        let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: 0) }
        self.collectionView.insertItemsAtIndexPaths(indexPaths)
    }

    public func deleteItemsAtIndexes(indexes: [Int]) {
        let indexPaths = indexes.map { NSIndexPath(forItem: $0, inSection: 0) }
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItemsAtIndexPaths(indexPaths)
        }, completion: nil)
    }

    public func cellForItemAtIndex(index: Int) -> UICollectionViewCell? {
        return self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0))
    }

    public func indexForCell(cell: UICollectionViewCell) -> Int {
        return self.collectionView.indexPathForCell(cell)?.item ?? NSNotFound
    }

    public func visibleCells() -> [UICollectionViewCell] {
        return self.collectionView.visibleCells()
    }

    @objc func indexesForVisibleItems() -> [Int] {
        return self.collectionView.indexPathsForVisibleItems().map { $0.item }
    }


    // MARK: - UICollectionView

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.delegate?.numberOfItemsInScroller(self) ?? 0
        if self.currentPage >= count {
            self.currentPage = min(0, count - 1)
        }
        return count
    }

    public func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath)
        self.delegate?.scroller(self, needsConfigureCell: cell, atIndex: indexPath.row)
        return cell
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.scroller?(self, didSelectItemAtIndex: indexPath.row)
    }


    // MARK: - UIScrollViewDelegate

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }

    public func scrollViewWillEndDragging(scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.pagingEnabled {
            var targetPage = self.pageForContentOffset(targetContentOffset.memory.x)
            if targetPage == self.currentPage {
                if velocity.x > 0 && targetPage < self.collectionView.numberOfItemsInSection(0) - 1 {
                    targetPage += 1
                } else if velocity.x < 0 && targetPage > 0 {
                    targetPage -= 1
                }
            }
            if !self.canScrollMultiplePages {
                if targetPage > self.currentPage + 1 {
                    targetPage = self.currentPage + 1
                } else if targetPage < self.currentPage - 1 {
                    targetPage = self.currentPage - 1
                }
            }
            let targetOffset = self.contentOffsetForPage(targetPage)
            targetContentOffset.memory.x = targetOffset
        }
    }

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.updateCurrentPage()
        self.delegate?.scrollerDidEndScrolling?(self)
    }

    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.updateCurrentPage()
        self.delegate?.scrollerDidEndScrolling?(self)
    }


    // MARK: - UIGestureRecognizer

    public func collectionViewDidTouchUp() {
        if self.pagingEnabled {
            self.setCurrentPage(self.currentPage, animated: true)
        }
    }

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer
                           otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


    // MARK: - Paging

    private func updateCurrentPage() {
        _currentPage = self.pageForContentOffset(self.collectionView.contentOffset.x)
    }

    public func setCurrentPage(page: Int, animated: Bool) {
        _currentPage = page
        let contentOffset = CGPoint(x: self.contentOffsetForPage(page), y: 0)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
    }

    public func contentOffsetForPage(page: Int) -> CGFloat {
        let pieceSize = (self.bounds.size.width - self.itemSize.width - self.itemSpacing * 2) / 2
        return CGFloat(page) * (self.contentInset + self.itemSize.width - pieceSize) - self.contentInset
    }

    public func pageForContentOffset(contentOffset: CGFloat) -> Int {
        return Int(
            (contentOffset + self.contentInset + self.itemSize.width / 2) / (self.itemSize.width + self.itemSpacing)
        )
    }

}

@objc public protocol HScrollerDelegate: NSObjectProtocol {

    func numberOfItemsInScroller(scroller: HScroller) -> Int
    func scroller(scroller: HScroller, needsConfigureCell rawCell: UICollectionViewCell, atIndex index: Int)
    optional func scroller(scroller: HScroller, didSelectItemAtIndex index: Int)
    optional func scrollerDidEndScrolling(scroller: HScroller)

}
