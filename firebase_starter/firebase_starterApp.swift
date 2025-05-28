//
//  firebase_starterApp.swift
//  firebase_starter
//
//  Created by Lyle Dean on 28/05/2025.
//

import FirebaseCore
import SwiftUI

#if os(iOS)
    import UIKit

    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_: UIApplication,
                         didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
        {
            if FirebaseApp.app() == nil {
                if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
                    print("Firebase plist found at: \(filePath)")
                    FirebaseApp.configure()
                } else {
                    print("Warning: GoogleService-Info.plist not found!")
                }
            }
            return true
        }
    }

#elseif os(macOS)
    import AppKit

    class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(_: Notification) {
            if FirebaseApp.app() == nil {
                if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
                    print("Firebase plist found at: \(filePath)")
                    FirebaseApp.configure()
                } else {
                    print("Warning: GoogleService-Info.plist not found!")
                }
            }
        }
    }
#endif

@main
struct firebase_starterApp: App {
    #if os(iOS)
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #elseif os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif

    init() {
        // Print the bundle identifier for debugging
        print("Bundle identifier: \(Bundle.main.bundleIdentifier ?? "unknown")")

        // Print all bundle paths for debugging
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("Bundle contents: \(contents)")
            } catch {
                print("Could not read bundle contents: \(error)")
            }
        }
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Verify Firebase initialization
                    if FirebaseApp.app() != nil {
                        print("Firebase successfully initialized")
                    } else {
                        print("Warning: Firebase not initialized")
                    }
                }
        }
    }
}
