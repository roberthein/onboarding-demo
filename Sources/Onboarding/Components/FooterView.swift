import UIKit

public final class FooterView: UIView {
    private lazy var welcomeLabelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        return view
    }()

    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.Welcome.footer
        label.textAlignment = .center
        label.clipsToBounds = false
        return label
    }()

    public lazy var continueButton: FooterButton = {
        let button = FooterButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var pageIndicatorStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public var onContinueTapped: (() -> Void)?

    private var theme: Theme?
    private var currentPageIndex: Int = 0
    private var pageCount: Int = 1
    private var welcomeLabelContainerHeightConstraint: NSLayoutConstraint?
    private var continueButtonHeightConstraint: NSLayoutConstraint?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        addSubview(welcomeLabelContainer)
        welcomeLabelContainer.addSubview(welcomeLabel)
        addSubview(continueButton)
        addSubview(pageIndicatorStack)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)

        let layout = Theme.fallback.layout
        let labelSectionHeight = layout.footerWelcomeLabelTopMargin + layout.footerWelcomeLabelHeight + layout.footerWelcomeLabelMarginToButton
        let containerHeight = welcomeLabelContainer.heightAnchor.constraint(equalToConstant: labelSectionHeight)
        welcomeLabelContainerHeightConstraint = containerHeight
        let buttonHeight = continueButton.heightAnchor.constraint(equalToConstant: layout.footerButtonHeight)
        continueButtonHeightConstraint = buttonHeight

        continueButton.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            welcomeLabelContainer.topAnchor.constraint(equalTo: topAnchor),
            welcomeLabelContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            welcomeLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerHeight,
            continueButton.topAnchor.constraint(equalTo: welcomeLabelContainer.bottomAnchor),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonHeight,
            welcomeLabel.topAnchor.constraint(equalTo: welcomeLabelContainer.topAnchor, constant: layout.footerWelcomeLabelTopMargin),
            welcomeLabel.leadingAnchor.constraint(equalTo: welcomeLabelContainer.leadingAnchor),
            welcomeLabel.trailingAnchor.constraint(equalTo: welcomeLabelContainer.trailingAnchor),
            welcomeLabel.heightAnchor.constraint(equalToConstant: layout.footerWelcomeLabelHeight),
            pageIndicatorStack.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: layout.footerPageIndicatorTopMargin),
            pageIndicatorStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageIndicatorStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc private func continueButtonTapped() {
        onContinueTapped?()
    }

    public func apply(theme: Theme) {
        self.theme = theme
        welcomeLabel.applyTitle2Style(theme: theme)
        welcomeLabelContainerHeightConstraint?.constant = theme.layout.footerWelcomeLabelTopMargin + theme.layout.footerWelcomeLabelHeight + theme.layout.footerWelcomeLabelMarginToButton
        continueButtonHeightConstraint?.constant = theme.layout.footerButtonHeight
        continueButton.apply(theme: theme)
        updatePageIndicatorAppearance()
    }

    public func setCurrentPage(_ pageIndex: Int, totalPages: Int) {
        currentPageIndex = max(0, min(pageIndex, max(1, totalPages) - 1))
        pageCount = max(1, totalPages)

        let layout = (theme ?? Theme.fallback).layout
        let dotSize = layout.footerPageIndicatorDotSize
        pageIndicatorStack.spacing = layout.footerPageIndicatorDotSpacing

        while pageIndicatorStack.arrangedSubviews.count < pageCount {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.clipsToBounds = true
            pageIndicatorStack.addArrangedSubview(dot)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
            ])
        }
        while pageIndicatorStack.arrangedSubviews.count > pageCount {
            pageIndicatorStack.arrangedSubviews.last?.removeFromSuperview()
        }
        updatePageIndicatorAppearance()
    }

    private func updatePageIndicatorAppearance() {
        guard let theme else { return }
        let dotSize = theme.layout.footerPageIndicatorDotSize
        for (index, dot) in pageIndicatorStack.arrangedSubviews.enumerated() {
            dot.backgroundColor = index == currentPageIndex
                ? theme.color.textPrimary
                : theme.color.textSecondary.withAlphaComponent(theme.layout.footerPageIndicatorInactiveAlpha)
            dot.layer.cornerRadius = dotSize / 2
        }
    }

    public func setAppearProgress(_ progress: CGFloat) {
        let layout = (theme ?? Theme.fallback).layout
        let slideDistance = layout.footerTotalHeight + layout.footerBottomPadding + layout.footerSlideOffset
        let eased = progress.easeOutBack()
        let y = slideDistance * (1 - eased)
        transform = CGAffineTransform(translationX: 0, y: y)

        let labelSlideStart = layout.footerButtonHeight + layout.footerWelcomeLabelMarginToButton
        let labelY = labelSlideStart * (1 - eased)
        welcomeLabel.transform = CGAffineTransform(translationX: 0, y: labelY)

        isHidden = false
        isUserInteractionEnabled = progress >= 1
    }

    public func setWelcomeLabelProgress(_ progress: CGFloat) {
        let clamped = min(1, max(0, progress))
        let layout = (theme ?? Theme.fallback).layout
        let visibleFactor = 1 - clamped

        let labelSectionHeight = layout.footerWelcomeLabelTopMargin + layout.footerWelcomeLabelHeight + layout.footerWelcomeLabelMarginToButton
        welcomeLabelContainerHeightConstraint?.constant = labelSectionHeight * visibleFactor
        welcomeLabel.alpha = max(0, 1 - clamped * 2)
        welcomeLabel.isHidden = clamped >= 0.5
    }

    public func setVisibilityProgress(_ progress: CGFloat) {
        let clamped = min(1, max(0, progress))
        let layout = (theme ?? Theme.fallback).layout
        let slideDistance = layout.footerTotalHeight + layout.footerBottomPadding + layout.footerSlideOffset
        transform = CGAffineTransform(translationX: 0, y: slideDistance * clamped)
        isHidden = clamped >= 1
        isUserInteractionEnabled = clamped < 1
    }
}
