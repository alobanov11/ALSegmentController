//
//  Created by Антон Лобанов on 20.02.2021.
//

import UIKit

open class ALSegmentViewController: UIViewController
{
    open var navigationBarStyles: ALSegmentNavigationBarStyles {
        .init(height: 42,
              font: .systemFont(ofSize: 14, weight: .regular),
              color: .black,
              selectedColor: .systemBlue,
              borderColor: .darkGray,
              backgroundColor: .cyan,
              borderHeight: 2)
    }

    public private(set) var headerView: UIView?

    public private(set) var refreshControl: UIRefreshControl?

    public private(set) var viewControllers: [IALSegmentContentViewControler] = []

    // MARK: - UI

    private lazy var navigationBarView = ALSegmentNavigationBarView(
        delegate: self,
        styles: self.navigationBarStyles,
        segments: self.viewControllers.map { $0.title ?? "*" }
    )

    private lazy var verticalCollectionView = ALSegmentVerticalCollectionView(
        adapter: self,
        refreshControl: self.refreshControl
    )

    private lazy var pageCollectionView = ALSegmentPageCollectionView(
        adapter: self
    )

    // MARK: - Variables

    private var visibleCollaborativeScrollView: UIScrollView {
        return self.viewControllers[self.pageCollectionView.selectedIndex]
            .segmentCollaborativeScrollView
    }

    private var lastCollaborativeScrollView: UIScrollView?

    // MARK: - UIKit

    public init(
        headerView: UIView? = nil,
        viewControllers: [IALSegmentContentViewControler],
        refreshControl: UIRefreshControl? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
        self.headerView = headerView
        self.viewControllers = viewControllers
        self.refreshControl = refreshControl
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers.forEach { $0.segmentContentDelegate = self }

        self.view.addSubview(self.verticalCollectionView)
        NSLayoutConstraint.activate([
            self.verticalCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.verticalCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.verticalCollectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.verticalCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        self.pageCollectionView.scrollToItem(at: 0)
    }

    // MARK: - Public

    public func reloadHeader() {
        self.verticalCollectionView.reloadItem(at: IndexPath(item: 0, section: 0))
    }
}

extension ALSegmentViewController: IALSegmentNavigationBarDelegate
{
    func segmentNavigationBar(didSelect item: Int) {
        self.pageCollectionView.scrollToItem(at: item, animated: true)
        self.syncCollaborativeScrollIfNeeded()
    }
}

extension ALSegmentViewController: IALSegmentVerticalCollectionAdapter
{
    func segmentVerticalCollection(headerView collectionView: UICollectionView) -> UIView? {
        self.headerView
    }

    func segmentVerticalCollection(navigationBarView collectionView: UICollectionView) -> UIView? {
        guard self.viewControllers.count > 1 else { return nil }
        return self.navigationBarView
    }

    func segmentVerticalCollection(pageCollectionView collectionView: UICollectionView) -> UIView {
        self.pageCollectionView
    }

    func segmentVerticalCollection(didScroll collectionView: UICollectionView) {
        self.syncVerticalScrollIfNeeded()
    }
}

extension ALSegmentViewController: IALSegmentPageCollectionAdapter
{
    func segmentPageCollection(shouldShow index: Int) -> Bool {
        self.viewControllers[index].canBeShowed
    }

    func segmentPageCollectionViewControllers() -> [UIViewController] {
        self.viewControllers
    }

    func segmentPageCollectionWillBeginDragging() {
        self.viewControllers.forEach {
            $0.segmentCollaborativeScrollView.isScrollEnabled = false
        }
        self.syncCollaborativeScrollIfNeeded()
    }

    func segmentPageCollectionDidEndDragging() {
        self.viewControllers.forEach {
            $0.segmentCollaborativeScrollView.isScrollEnabled = true
        }
    }

    func segmentPageCollection(didScroll point: CGPoint) {
        self.navigationBarView.didHorizontalScroll(with: point)
    }
}

extension ALSegmentViewController: IALSegmentContentDelegate
{
    public func segmentContent(didScroll scrollView: UIScrollView) {
        self.syncVerticalScrollIfNeeded()
    }
}

// MARK: - Private

private extension ALSegmentViewController
{
    func syncVerticalScrollIfNeeded() {
        guard self.headerView != nil else {
            self.verticalCollectionView.contentOffsetY = 0
            return
        }

        let ctx = (
            headerH: self.verticalCollectionView.sizeForHeader().height,
            verticalY: self.verticalCollectionView.contentOffsetY,
            lastVerticalY: self.verticalCollectionView.lastContentOffsetY,
            collaborativeY: self.visibleCollaborativeScrollView.contentOffset.y
        )

        let collaborativeY = ctx.verticalY >= ctx.headerH
            ? ctx.collaborativeY
            : ctx.collaborativeY > 0 && ctx.lastVerticalY >= ctx.headerH
            ? ctx.collaborativeY
            : 0

        let verticalY = collaborativeY > 0
            ? ctx.headerH
            : ctx.verticalY

        self.visibleCollaborativeScrollView.contentOffset.y = max(0, collaborativeY)
        self.verticalCollectionView.contentOffsetY = min(ctx.headerH, verticalY)
        self.verticalCollectionView.lastContentOffsetY = min(ctx.headerH, verticalY)
        self.lastCollaborativeScrollView = self.visibleCollaborativeScrollView
    }

    func syncCollaborativeScrollIfNeeded() {
        guard let collaborativeScrollView = self.lastCollaborativeScrollView,
              self.headerView != nil
        else {
            return
        }

        let ctx = (
            collaborativeY: collaborativeScrollView.contentOffset.y,
            navBarHeight: self.navigationBarStyles.height
        )

        self.viewControllers
            .map { $0.segmentCollaborativeScrollView }
            .filter { $0 != collaborativeScrollView }
            .forEach {
                if ctx.collaborativeY == 0 && $0.contentOffset.y > 0 { $0.contentOffset.y = 0 }
            }
    }
}
