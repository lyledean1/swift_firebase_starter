//
//  FirestoreModel.swift
//  powerpal
//
//  Created by Lyle Dean on 02/11/2024.
//

import Firebase
import FirebaseFirestore
import Foundation

// example user data
struct UserOverviewData: Codable {
    let enabled: Bool
    let values: [String: Double]



    // First, define the coding keys
    enum CodingKeys: String, CodingKey {
        case enabled
        case values
    }

    // Add custom init decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? false
        let values = try container.decodeIfPresent([String: Double].self, forKey: .values) ?? [:]
        self.values = values
    }

    // Add regular initializer
    init(enabled: Bool = false) {
        self.enabled = enabled
        self.values = [:]

    }

    // Add encode method to complete Codable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabled, forKey: .enabled)
    }
}

extension UserOverviewData {
    static func fetchUserSummaryFromFirestore(userId: String) async throws -> UserOverviewData {
        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(userId)

        let snapshot = try await docRef.getDocument()
        return try snapshot.data(as: UserOverviewData.self)
    }

    func saveToFirestore(userId: String) async throws {
        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(userId)

        try docRef.setData(from: self)
    }
}

@MainActor
class FirestoreViewModel: ObservableObject {
    let db = Firestore.firestore()
    @Published var userSummary: UserOverviewData?

    func getUserData(userId: String) async throws {
        userSummary = try await UserOverviewData.fetchUserSummaryFromFirestore(userId: userId)
    }

    func setUserData(userId: String, enabled: Bool) async throws {
        let data = UserOverviewData(enabled: enabled)
        try await data.saveToFirestore(userId: userId)
        userSummary = data
    }

}
