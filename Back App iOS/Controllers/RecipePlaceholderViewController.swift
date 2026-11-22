// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import BakingRecipeStrings
import BakingRecipeUIFoundation

/// Fills the detail column of the split view while no recipe is shown,
/// e.g. on iPad or the unfolded iPhone Duo right after launch or after deleting the shown recipe.
final class RecipePlaceholderViewController: UIViewController {

    /// The outline bread from the app's assets, in the purple of the recipe cells
    private var image: UIImage? {
        UIImage(named: "bread")?.withRenderingMode(.alwaysTemplate)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor

        if #available(iOS 17.0, *) {
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.image = image
            configuration.imageProperties.tintColor = .cellBackgroundColor
            configuration.imageProperties.maximumSize = CGSize(width: 110, height: 110)
            configuration.text = Strings.noRecipeSelected
            configuration.secondaryText = Strings.noRecipeSelectedHint
            configuration.secondaryTextProperties.color = .secondaryTextColor ?? .secondaryLabel
            contentUnavailableConfiguration = configuration
        } else {
            addFallbackContent()
        }
    }

    /// The same layout as `UIContentUnavailableConfiguration.empty()`, for iOS 15 and 16
    private func addFallbackContent() {
        let imageView = UIImageView(image: image)
        imageView.tintColor = .cellBackgroundColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 110),
            imageView.heightAnchor.constraint(equalToConstant: 110),
        ])

        let titleLabel = UILabel()
        titleLabel.text = Strings.noRecipeSelected
        titleLabel.font = .preferredFont(forTextStyle: .title3).withTraits(.traitBold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let hintLabel = UILabel()
        hintLabel.text = Strings.noRecipeSelectedHint
        hintLabel.font = .preferredFont(forTextStyle: .body)
        hintLabel.adjustsFontForContentSizeCategory = true
        hintLabel.textColor = .secondaryTextColor ?? .secondaryLabel
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, hintLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(16, after: imageView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
}

private extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
