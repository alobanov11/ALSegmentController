//
//  Created by Антон Лобанов on 22.02.2021.
//

import UIKit

public struct ALSegmentNavigationBarStyles
{
    public let height: CGFloat
    public let font: UIFont
    public let color: UIColor
    public let selectedColor: UIColor
    public let borderColor: UIColor
    public let backgroundColor: UIColor
    public let borderHeight: CGFloat

    public init(
        height: CGFloat,
        font: UIFont,
        color: UIColor,
        selectedColor: UIColor,
        borderColor: UIColor,
        backgroundColor: UIColor,
        borderHeight: CGFloat
    ) {
        self.height = height
        self.font = font
        self.color = color
        self.selectedColor = selectedColor
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
        self.borderHeight = borderHeight
    }
}

protocol IALSegmentNavigationBarDelegate: AnyObject {
    func segmentNavigationBar(didSelect item: Int)
}

final class ALSegmentNavigationBarView: UIView
{
    private lazy var stackView: UIStackView = {
        let subviews = self.segments.enumerated().map { item -> UIView in
            let view = UIButton(type: .custom)
            view.setTitle(item.element, for: .normal)
            view.setTitleColor(item.offset == 0 ? self.styles.selectedColor : self.styles.color, for: .normal)
            view.titleLabel?.font = self.styles.font
            view.contentHorizontalAlignment = .center
            view.contentVerticalAlignment = .center
            view.tag = item.offset
            view.addTarget(self, action: #selector(self.didTapOnSegment), for: .touchUpInside)
            return view
        }
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        return stackView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.styles.borderColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var selectedSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.styles.selectedColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var selectedSeparatorLeadingConstraint = self.selectedSeparatorView.leadingAnchor.constraint(
        equalTo: self.leadingAnchor,
        constant: 0
    )

    private weak var delegate: IALSegmentNavigationBarDelegate!

    private let styles: ALSegmentNavigationBarStyles
    private let segments: [String]

    init(
        delegate: IALSegmentNavigationBarDelegate,
        styles: ALSegmentNavigationBarStyles,
        segments: [String]
    ) {
        self.delegate = delegate
        self.styles = styles
        self.segments = segments
        super.init(frame: .zero)
        self.backgroundColor = styles.backgroundColor
        self.initializeView()
        self.initializeLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didHorizontalScroll(with point: CGPoint) {
        let width = self.frame.width
        let multiplier = width == 0 ? 0 : (point.x / width) - 1
        self.updateSelectedButton(with: Int(multiplier))
        self.selectedSeparatorLeadingConstraint.constant = (
            width / CGFloat(self.segments.count)
        ) * multiplier
    }

    @objc
    private func didTapOnSegment(_ sender: UIButton) {
        self.updateSelectedButton(with: sender.tag)
        self.selectedSeparatorLeadingConstraint.constant = (
            self.frame.width / CGFloat(self.segments.count)
        ) * CGFloat(sender.tag)
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        self.delegate?.segmentNavigationBar(didSelect: sender.tag)
    }

    private func updateSelectedButton(with index: Int) {
        self.stackView.arrangedSubviews
            .compactMap { $0 as? UIButton }
            .enumerated()
            .forEach {
                $0.element.setTitleColor(index == $0.offset
                                            ? self.styles.selectedColor
                                            : self.styles.color, for: .normal)
            }
    }

    private func initializeView() {
        self.addSubview(self.stackView)
        self.addSubview(self.separatorView)
        self.addSubview(self.selectedSeparatorView)
    }

    private func initializeLayout() {
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.styles.height),
        ])
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        NSLayoutConstraint.activate([
            self.separatorView.heightAnchor.constraint(equalToConstant: self.styles.borderHeight),
            self.separatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        NSLayoutConstraint.activate([
            self.selectedSeparatorView.heightAnchor.constraint(equalToConstant: self.styles.borderHeight),
            self.selectedSeparatorLeadingConstraint,
            self.selectedSeparatorView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1 / CGFloat(self.segments.count)),
            self.selectedSeparatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}

private extension UIStackView
{
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))

        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
