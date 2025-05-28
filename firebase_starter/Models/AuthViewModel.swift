import AuthenticationServices
import Combine
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn

final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var firebaseUser: User?
    @Published var state: AuthState = .init()

    private lazy var cancellables: Set<AnyCancellable> = .init()

    init() {
        setupAuthStateListener()
        checkExistingAuth()
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Auth State Management

    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.firebaseUser = user
                self?.isLoggedIn = user != nil
            }
        }
    }

    private func checkExistingAuth() {
        if let currentUser = Auth.auth().currentUser {
            firebaseUser = currentUser
            isLoggedIn = true
        }
    }

    // MARK: - Sign in with Apple

    func SignInWithApple(result: Result<ASAuthorization, any Error>, currentNonce: String?) {
        switch result {
        case let .success(authResults):
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }

                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                signInWithFirebase(credential: credential)
            default:
                break
            }
        default:
            break
        }
    }

    // MARK: - Sign in with Google

    @MainActor
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController
        else {
            throw AuthError.presentationError
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.invalidCredential
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            signInWithFirebase(credential: credential)

        } catch {
            throw error
        }
    }

    // MARK: - Firebase Authentication

    private func signInWithFirebase(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                self?.firebaseUser = authResult?.user
                self?.isLoggedIn = true
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            // Also sign out from Google if it was used
            GIDSignIn.sharedInstance.signOut()

            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.firebaseUser = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

enum AuthError: Error {
    case missingClientID
    case presentationError
    case invalidCredential
}
