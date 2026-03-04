import QuartzCore
import UIKit

public final class SkillPickerPageView: ScrollablePageView {
    private lazy var faceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: SkillLevel.intermediate.faceImageName)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.SkillPicker.title
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizedStrings.SkillPicker.subtitle
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var pickerView: SkillLevelPickerView = {
        let skillLevelPickerView = SkillLevelPickerView()
        skillLevelPickerView.translatesAutoresizingMaskIntoConstraints = false
        return skillLevelPickerView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var stackViewLeadingConstraint: NSLayoutConstraint?
    private var stackViewTrailingConstraint: NSLayoutConstraint?
    private var theme: Theme?
    private var translationX: CGFloat = 0
    private var headBobDisplayLink: CADisplayLink?
    private var headBobStartTime: CFTimeInterval = 0
    private var congratsPageProgress: CGFloat = 0
    private var selectedSkillLevel: SkillLevel?

    var onPickerSelect: ((SkillLevel?) -> Void)? {
        get { pickerView.onSelect }
        set { pickerView.onSelect = newValue }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        stackView.addArrangedSubview(faceImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(pickerView)

        centeredContentView.addSubview(stackView)

        let leading = stackView.leadingAnchor.constraint(equalTo: centeredContentView.leadingAnchor)
        let trailing = stackView.trailingAnchor.constraint(equalTo: centeredContentView.trailingAnchor)
        stackViewLeadingConstraint = leading
        stackViewTrailingConstraint = trailing
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: centeredContentView.topAnchor),
            leading,
            trailing,
            stackView.bottomAnchor.constraint(equalTo: centeredContentView.bottomAnchor),
        ])
        scrollView.clipsToBounds = false
    }

    public func setSelected(_ level: SkillLevel?, animate: Bool = false) {
        selectedSkillLevel = level
        pickerView.setSelected(level)
        updateFaceImage(for: level, animate: animate)
    }

    public func setCongratsPageProgress(_ progress: CGFloat) {
        congratsPageProgress = progress
        if progress > 0 {
            if headBobDisplayLink == nil {
                startHeadBobbing()
            }
        } else {
            stopHeadBobbing()
        }
    }

    private func updateFaceImage(for level: SkillLevel?, animate: Bool = false) {
        let imageName = level?.faceImageName ?? SkillLevel.intermediate.faceImageName
        faceImageView.image = UIImage(named: imageName)

        if animate {
            bounceRotateFaceImage()
        }
    }

    private func bounceRotateFaceImage() {
        stopHeadBobbing()
        let rotationAngle = theme?.skillPickerFace.rotationAngle ?? 0.2
        let bounceDuration = theme?.skillPickerFace.bounceDuration ?? 0.45
        let bounceDamping = theme?.skillPickerFace.bounceDamping ?? 0.55
        let bounceVelocity = theme?.skillPickerFace.bounceVelocity ?? 0.3
        faceImageView.transform = CGAffineTransform(rotationAngle: -rotationAngle).scaledBy(x: 1.1, y: 1.1)
        UIView.animate(
            withDuration: bounceDuration,
            delay: 0,
            usingSpringWithDamping: bounceDamping,
            initialSpringVelocity: bounceVelocity
        ) {
            self.faceImageView.transform = .identity
        } completion: { [weak self] _ in
            self?.restartHeadBobbingIfNeeded()
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopHeadBobbing()
        }
    }

    private func startHeadBobbing() {
        headBobStartTime = CACurrentMediaTime()
        headBobDisplayLink = CADisplayLink(target: self, selector: #selector(headBobTick(_:)))
        headBobDisplayLink?.add(to: .main, forMode: .common)
    }

    private func stopHeadBobbing() {
        headBobDisplayLink?.invalidate()
        headBobDisplayLink = nil
        faceImageView.transform = .identity
    }

    private func restartHeadBobbingIfNeeded() {
        if congratsPageProgress > 0 {
            startHeadBobbing()
        }
    }

    @objc private func headBobTick(_ link: CADisplayLink) {
        let intensity = congratsPageProgress.easeOutCubic()
        guard intensity > 0.001 else {
            faceImageView.transform = .identity
            return
        }
        let t = CACurrentMediaTime() - headBobStartTime
        let params = SkillLevel.HeadBobParams.for(selectedSkillLevel)
        let bobY = (sin(t * params.freq1) * params.bobAmp1 + sin(t * params.freq2 + params.phase2) * params.bobAmp2 + sin(t * params.freq3 - params.phase3) * params.bobAmp3) * intensity
        let tilt = (sin(t * params.tiltFreq1 + 0.3) * params.tiltAmp + sin(t * params.tiltFreq2 + 2.1) * params.tiltAmp * 0.5) * intensity
        let sway = sin(t * params.swayFreq + 0.7) * params.swayAmp * intensity
        faceImageView.transform = CGAffineTransform(translationX: sway, y: bobY)
            .rotated(by: tilt)
    }
}

extension SkillPickerPageView: PageContentView {
    public func apply(theme: Theme) {
        self.theme = theme
        stackView.spacing = theme.spacing.item
        let horizontalMargin = theme.skillPickerPage.horizontalMargin
        stackViewLeadingConstraint?.constant = horizontalMargin
        stackViewTrailingConstraint?.constant = -horizontalMargin
        titleLabel.applyLargeTitleStyle(theme: theme)
        subtitleLabel.applyTitle2StyleSubdued(theme: theme)
        pickerView.apply(theme: theme)

        stackView.setCustomSpacing(theme.spacing.content, after: faceImageView)
        stackView.setCustomSpacing(0, after: titleLabel)
        stackView.setCustomSpacing(theme.spacing.content, after: subtitleLabel)
    }
}

extension SkillPickerPageView {
    public func updateAppearance(progress: CGFloat) {
        titleLabel.alpha = progress
        subtitleLabel.alpha = progress
        pickerView.alpha = progress
    }
}

extension SkillPickerPageView: ScrollTranslationApplicable {
    public func applyScrollTranslation(contentOffsetX: CGFloat, pageWidth: CGFloat) {
        guard pageWidth > 0 else { return }
        let skillPickerPageIndex: CGFloat = 2
        translationX = contentOffsetX - skillPickerPageIndex * pageWidth
        if translationX > 0 {
            centeredContentView.transform = CGAffineTransform(translationX: translationX, y: 0)
        }
    }
}
