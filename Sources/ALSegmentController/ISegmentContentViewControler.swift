//
//  Created by Антон Лобанов on 21.02.2021.
//

import UIKit

public protocol ISegmentContentViewControler: UIViewController
{
    var canBeShowed: Bool { get }
    var segmentContentDelegate: ISegmentContentDelegate? { get set }
    var segmentCollaborativeScrollView: ICollaborativeScrollView { get }
}

public protocol ISegmentContentDelegate: AnyObject
{
    func segmentContent(didScroll scrollView: UIScrollView)
}
