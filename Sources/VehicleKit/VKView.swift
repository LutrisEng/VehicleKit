import SwiftUI

public struct VKView: View {
    indirect enum ViewType {
        case teslaAuthenticationView(view: VKTeslaAPI.AuthenticationView)
    }

    let type: ViewType

    public var body: some View {
        switch type {
        case .teslaAuthenticationView(let view): view
        }
    }
}
