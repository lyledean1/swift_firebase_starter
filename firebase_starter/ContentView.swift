//
//  ContentView.swift
//  firebase_starter
//
//  Created by Lyle Dean on 28/05/2025.
//

import SwiftUI
import AuthenticationServices
import Charts
import CryptoKit
import FirebaseAuth
import GoogleSignIn
import SwiftUI

extension Color {
    static var systemGray6: Color {
        #if os(iOS)
            return Color(uiColor: .systemGray6)
        #elseif os(macOS)
            // macOS doesn't have direct systemGray6 equivalent
            // Using controlBackgroundColor which is similar in appearance
            return Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var systemBackground: Color {
        #if os(iOS)
            return Color(uiColor: .systemBackground)
        #elseif os(macOS)
            return Color(nsColor: .windowBackgroundColor)
        #else
            return .white // Fallback
        #endif
    }
}

struct ContentView: View {
    @StateObject private var authViewModel: AuthViewModel = .init()
    @StateObject private var firestoreViewModel: FirestoreViewModel = .init()

    var body: some View {
        Group {
            if !authViewModel.isLoggedIn {
                SignInView(authViewModel: authViewModel)
            } else {
                MainTabView(authViewModel: authViewModel, firestoreViewModel: firestoreViewModel)
            }
        }
        .onChange(of: authViewModel.isLoggedIn) { newValue in
            if newValue {
                loadUserData()
            }
        }
    }

    private func loadUserData() {
        Task {
            if let uid = authViewModel.firebaseUser?.uid {
                // do something in fireabse i.e load user data
            }
        }
    }
}

// Tab View Container
struct MainTabView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel

    var body: some View {
        TabView {
            ExampleView(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "bolt")
                    Text("Example")
                }
            ProfileView(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .onOpenURL { url in
            // Handle the callback URL when the app is opened via the custom scheme
            print("App opened with URL: \(url)") // Debug logging

            Task {
                do {
                    guard let firebaseUser = authViewModel.firebaseUser else {
                        print("No firebase user found")
                        return
                    }

                    let tokenResult = try await firebaseUser.getIDTokenResult()
                    // do something with token
                    // i.e use it to authenticate to an API
                } catch {
                    print("Error getting token: \(error)")
                }
            }
        }.task {
            do {
                guard let uid = authViewModel.firebaseUser?.uid else {
                    return
                }
                try await firestoreViewModel.getUserData(userId: uid)
            } catch {
                print("Error getting user data: \(error)")
            }
        }
    }
}

// Sign In View
struct SignInView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var currentNonce: String?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            // Apple Sign In
            SignInWithAppleButton(
                onRequest: { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                },
                onCompletion: { result in
                    authViewModel.SignInWithApple(result: result, currentNonce: currentNonce)
                }
            )
            .frame(width: 280, height: 45, alignment: .center)

            // Google Sign In
            Button {
                Task {
                    do {
                        try await authViewModel.signInWithGoogle()
                    } catch {
                        print("Google Sign-In error: \(error)")
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image("google_logo") // Make sure to add this to your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Text("Sign in with Google")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(width: 280, height: 45)
                .background(colorScheme == .dark ? Color.white : Color.white)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
            .cornerRadius(5)
        }
        .padding()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            for random in randoms {
                if remainingLength == 0 {
                    continue
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// Preview provider
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(authViewModel: AuthViewModel())
    }
}

#Preview {
    ContentView()
}
