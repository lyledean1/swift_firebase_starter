//
//  ProfileView.swift
//  powerpal
//
//  Created by Lyle Dean on 09/11/2024.
//

import SwiftUI

struct ExampleView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Hello world")
            }
            .navigationTitle("Example")
        }
    }
}
