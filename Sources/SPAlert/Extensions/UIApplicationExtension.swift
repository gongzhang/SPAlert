//
//  UIApplicationExtension.swift
//
//
//  Created by Gong Zhang on 2023/9/12.
//

#if !os(visionOS)
import UIKit

protocol DeprecatedUIApplication {
    var deprecatedKeyWindow: UIWindow? { get }
}

extension UIApplication: DeprecatedUIApplication {
    
    @available(iOS, deprecated: 18.0)
    public var lastInteractedKeyWindow: UIWindow? {
        (self as DeprecatedUIApplication).deprecatedKeyWindow
    }
    
    @available(iOS, deprecated: 13.0)
    internal var deprecatedKeyWindow: UIWindow? {
        self.keyWindow
    }
    
}
#endif
