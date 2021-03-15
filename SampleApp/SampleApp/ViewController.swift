//
//  Created by Антон Лобанов on 16.02.2021.
//

import UIKit
import ALSegmentView

final class HeaderView: UIView
{
    init() {
        super.init(frame: .zero)
        let innerView = UILabel()
        innerView.text = "Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello"
        innerView.font = .systemFont(ofSize: 48)
        innerView.numberOfLines = 0
        innerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(innerView)
        self.backgroundColor = .random
        NSLayoutConstraint.activate([
            innerView.topAnchor.constraint(equalTo: self.topAnchor),
            innerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            innerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            innerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ContentViewController: UIViewController, IALSegmentContentViewControler
{
    var canBeShowed: Bool { true }
    var segmentContentDelegate: IALSegmentContentDelegate?
    var segmentCollaborativeScrollView: IALCollaborativeScrollView { self.collectionView }
    
    private(set) lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset.top = 20
        flowLayout.sectionInset.bottom = 20
        flowLayout.minimumLineSpacing = 20
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }()

    private(set) lazy var collectionView: ALCollaborativeCollectionView = {
        let collectionView = ALCollaborativeCollectionView(
            frame: .zero,
            collectionViewLayout: self.collectionViewLayout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self)
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
}

extension ContentViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        Int.random(in: 5...10)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: UICollectionViewCell.self),
            for: indexPath
        )
        cell.layer.cornerRadius = 20
        cell.backgroundColor = .random
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: collectionView.frame.size.width - 40, height: 300)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.segmentContentDelegate?.segmentContent(didScroll: scrollView)
    }
}

final class ViewController: ALSegmentViewController
{
    init() {
        let refreshControl = UIRefreshControl()

        super.init(
            headerView: HeaderView(),
            viewControllers: Array(0...3).map {
                let viewController = ContentViewController()
                viewController.title = "\($0)"
                return viewController
            },
            refreshControl: refreshControl
        )

        refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }

    @objc func pullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.refreshControl?.endRefreshing()
        }
    }
}

// -

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
