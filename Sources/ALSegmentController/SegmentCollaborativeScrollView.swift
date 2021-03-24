//
//  Created by Антон Лобанов on 20.02.2021.
//

import UIKit

public protocol ICollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate
{
}

open class CollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate, ICollaborativeScrollView
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}

open class CollaborativeCollectionView: UICollectionView, UIGestureRecognizerDelegate, ICollaborativeScrollView
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}

open class CollaborativeTableView: UITableView, UIGestureRecognizerDelegate, ICollaborativeScrollView
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}
