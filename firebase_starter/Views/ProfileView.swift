//
//  ProfileView.swift
//  powerpal
//
//  Created by Lyle Dean on 09/11/2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color(red: 0, green: 0, blue: 0.5))
                .clipShape(Capsule())
            }
            .navigationTitle("Profile")
        }
    }
}
