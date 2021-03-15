//
//  Created by Антон Лобанов on 21.02.2021.
//

import UIKit

public protocol IALSegmentContentViewControler: UIViewController
{
    var canBeShowed: Bool { get }
    var segmentContentDelegate: IALSegmentContentDelegate? { get set }
    var segmentCollaborativeScrollView: IALCollaborativeScrollView { get }
}

public protocol IALSegmentContentDelegate: AnyObject
{
    func segmentContent(didScroll scrollView: UIScrollView)
}
