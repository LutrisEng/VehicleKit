import Foundation

public enum VKAuthenticationResponse {
    case token(token: String)
    case usernamePassword(username: String, password: String)
    case viewDismissed
}
