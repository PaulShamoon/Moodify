//
//  EX.swift
//  Moodify
//
//  Created by Nazanin Mahmoudi on 11/29/24.
//

extension UIDevice {
    var hasNotch: Bool {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets.top ?? 0 > 20
    }
}
