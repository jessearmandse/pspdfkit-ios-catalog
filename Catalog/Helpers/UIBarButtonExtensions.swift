//
//  Copyright © 2021-2022 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import UIKit

private var UIBarButtonActionBlockKey: Character = "0"

extension UIBarButtonItem {

    typealias UIBarButtonItemAction = (_ sender: AnyObject?) -> Void

    /// Creates a new `UIBarButtonItem` that executes the given action block.
    @objc(psc_initWithTitle:style:action:)
    convenience init(title: String, style: UIBarButtonItem.Style, action: @escaping UIBarButtonItemAction) {
        self.init(title: title, style: style, target: nil, action: #selector(psc_executeAction(_:)))
        target = self

        self.actionBlock = action
    }

    private var actionBlock: UIBarButtonItemAction? {
        get { objc_getAssociatedObject(self, &UIBarButtonActionBlockKey) as? UIBarButtonItemAction }
        set { objc_setAssociatedObject(self, &UIBarButtonActionBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    @objc private func psc_executeAction(_ sender: AnyObject?) {
        actionBlock?(sender)
    }

    /// Creates a `UIBarButtonItem` with a context menu that is backwards compatible on iOS 13.
    /// On iOS 13, the context menu can be invoked by "Tap and Hold" action on the bar button item.
    static func contextMenuBarButtonItem(image: UIImage, menu: UIMenu) -> UIBarButtonItem {
        if #available(iOS 14, *) {
            return UIBarButtonItem(title: nil, image: image, menu: menu)
        } else {
            return CompatibleBarButtonItem(image: image, menu: menu)
        }
    }
}

/// `UIBarButtonItem` subclass that allows displaying a context menu.
/// Invoking the context menu required "Tap and Hold" as opposed to single tap like in iOS 14 and above.
class CompatibleBarButtonItem: UIBarButtonItem, UIContextMenuInteractionDelegate {

    private var internalMenu: UIMenu?

    private let internalButton = UIButton(type: .system)

    init(image: UIImage, menu: UIMenu) {
        super.init()

        internalMenu = menu
        internalButton.sizeThatFits(CGSize(width: 44, height: 44))
        internalButton.setImage(image, for: .normal)
        let interaction = UIContextMenuInteraction(delegate: self)
        internalButton.addInteraction(interaction)
        customView = internalButton
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let menu = internalMenu
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in menu }
    }

    override var image: UIImage? {
        get {
            internalButton.image(for: .normal)
        }
        set {
            internalButton.setImage(newValue, for: .normal)
        }
    }
}
