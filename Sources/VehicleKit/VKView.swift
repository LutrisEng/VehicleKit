import SwiftUI

public struct VKView: View {
    indirect enum ViewType {
        case empty
        #if canImport(WebKit) && canImport(UIKit)
        case teslaAuthenticationView(view: VKTeslaAPI.AuthenticationView)
        #endif
    }

    let type: ViewType

    public var body: some View {
        switch type {
        case .empty: EmptyView()
        #if canImport(WebKit) && canImport(UIKit)
        case .teslaAuthenticationView(let view): view
        #endif
        }
    }
}
