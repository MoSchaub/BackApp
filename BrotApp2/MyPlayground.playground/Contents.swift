import AppKit

var mainScreen: CGRect{
    let nsRect = NSScreen.main!.visibleFrame
    return CGRect(origin: nsRect.origin, size: CGSize(width: nsRect.width, height: nsRect.height))
}

mainScreen


