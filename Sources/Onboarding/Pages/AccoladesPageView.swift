import UIKit

public final class AccoladesPageView: ScrollablePageView {

    public init() {
        super.init(frame: .zero)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    private func buildView() {
        isUserInteractionEnabled = false
    }
}
