//
//  FirestoreModel.swift
//  powerpal
//
//  Created by Lyle Dean on 02/11/2024.
//

import Firebase
import FirebaseFirestore
import Foundation

struct UserOverviewData: Codable {
    let linked_strava: Bool
    let last_seven_days: [String: Double]
    let last_thirty_days: [String: Double]
    let last_ninety_days: [String: Double]


    // First, define the coding keys
    enum CodingKeys: String, CodingKey {
        case linked_strava
        case last_seven_days
        case last_thirty_days
        case last_ninety_days
    }

    // Add custom init decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        linked_strava = try container.decodeIfPresent(Bool.self, forKey: .linked_strava) ?? false
        let lastSevenDays = try container.decodeIfPresent([String: Double].self, forKey: .last_seven_days) ?? [:]
        let lastThirtyDays = try container.decodeIfPresent([String: Double].self, forKey: .last_thirty_days) ?? [:]
        let lastNinetyDays = try container.decodeIfPresent([String: Double].self, forKey: .last_ninety_days) ?? [:]
        self.last_seven_days = lastSevenDays
        self.last_thirty_days = lastThirtyDays
        self.last_ninety_days = lastNinetyDays
    }

    // Add regular initializer
    init(linked_strava: Bool = false) {
        self.linked_strava = linked_strava
        self.last_ninety_days = [:]
        self.last_seven_days = [:]
        self.last_thirty_days = [:]
    }

    // Add encode method to complete Codable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(linked_strava, forKey: .linked_strava)
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

    func setUserData(userId: String, linkedStrava: Bool) async throws {
        let data = UserOverviewData(linked_strava: linkedStrava)
        try await data.saveToFirestore(userId: userId)
        userSummary = data
    }

}
