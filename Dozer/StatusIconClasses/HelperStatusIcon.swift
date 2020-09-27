/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Cocoa
import Defaults

private struct StatusIconLength {
    static var show: CGFloat {
        Defaults[.buttonPadding]
    }
    static let hide: CGFloat = 10_000
}

class HelperstatusIcon {
    var type: StatusIconType
    var isShown: Bool = true
    var invisible: Bool = false {
        didSet {
            isShown ? show() : hide()
        }
    }
    var useSingleIcon: Bool = false {
        didSet {
            guard let statusIconButton = statusIcon.button else {
                fatalError("helper status item button failed")
            }
            statusIconButton.imagePosition = useSingleIcon ? .imageRight : .imageOnly
        }
    }
    let statusIcon: NSStatusItem = NSStatusBar.system.statusItem(withLength: StatusIconLength.show)

    init() {
        type = .normal
        statusIcon.length = StatusIconLength.show
        statusIcon.highlightMode = false
        guard let statusIconButton = statusIcon.button else {
            fatalError("helper status item button failed")
        }
        statusIconButton.target = self
        statusIconButton.action = #selector(statusIconClicked(_:))
        setIcon()
        statusIconButton.sendAction(on: [.leftMouseDown, .rightMouseDown])
    }

    deinit {
        print("status item has been deallocated")
    }

    func show() {
        isShown = true
        statusIcon.length = invisible ? 2 : showIconLength()
    }

    func hide() {
        isShown = false
        statusIcon.length = 600
//        statusIcon.length = 750
//        statusIcon.length = StatusIconLength.hide
    }

    func toggle() {
        if isShown {
            hide()
        } else {
            show()
        }
    }

    func setIcon() {
        guard let statusIconButton = statusIcon.button else {
            fatalError("helper status item button failed")
        }
        statusIconButton.image = Icons().helperstatusIcon
        statusIconButton.image!.isTemplate = true
    }

    func showIconLength() -> CGFloat {
        if useSingleIcon && StatusIconLength.show < 25 {
            // .imageTrailing position causes the icon to jump around if the
            // length is less than 25px. (There might be a better way to fix this.)
            return 25.0
        }
        return StatusIconLength.show
    }

    func setSize() {
        if isShown && !invisible {
            statusIcon.length = showIconLength()
        }
        guard let statusIconButton = statusIcon.button else {
            fatalError("helper status item button failed")
        }
        let image = statusIconButton.image
        var size = DozerIcons.shared.iconFontSize
        if self.type == .remove {
            size /= 2
        }
        image?.size = NSSize(width: size, height: size)
        statusIconButton.image = image
    }

    func showRemoveIcons() {}

    @objc
    func statusIconClicked(_ sender: AnyObject?) {}

    var xPositionOnScreen: CGFloat {
        guard let dozerIconFrame = statusIcon.button?.window?.frame else {
            return 0
        }
        let dozerIconXPosition = dozerIconFrame.origin.x
        return dozerIconXPosition
    }
}
