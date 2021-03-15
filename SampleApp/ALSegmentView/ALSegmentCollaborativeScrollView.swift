//
//  Created by Антон Лобанов on 20.02.2021.
//

import UIKit

public protocol IALCollaborativeScrollView: UIScrollView
{
}

open class ALCollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate, IALCollaborativeScrollView
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}

open class ALCollaborativeCollectionView: UICollectionView, UIGestureRecognizerDelegate, IALCollaborativeScrollView
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}

open class ALCollaborativeTableView: UITableView, UIGestureRecognizerDelegate, IALCollaborativeScrollView
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}
