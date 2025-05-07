//
//  SettingsViewModel.swift
//  MemoTrip
//
//  Created by 조수원 on 4/29/25.
//

import SwiftUI
import CoreData

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var profileImage: UIImage? = nil
    @Published var isLoggedOut: Bool = false

    private let context = PersistenceController.shared.container.viewContext
    private var currentUser: User?

    init() {
        fetchCurrentUser()
    }

    func fetchCurrentUser() {
        let request = User.fetchRequest()
        do {
            let users = try context.fetch(request)
            if let user = users.first {
                currentUser = user
                userEmail = user.email ?? "Unknown"
                if let imageData = user.profileImage,
                   let uiImage = UIImage(data: imageData) {
                    profileImage = uiImage
                }
            }
        } catch {
            print("사용자 정보 가져오기 실패: \(error.localizedDescription)")
        }
    }

    func updateProfileImage(image: UIImage) {
        guard let user = currentUser else { return }
        if let data = image.jpegData(compressionQuality: 0.8) {
            user.profileImage = data
            saveContext()
            profileImage = image
        }
    }

    func logout() {
        let request = User.fetchRequest()
        do {
            let users = try context.fetch(request)
            for user in users {
                context.delete(user)
            }
            try context.save()
            isLoggedOut = true
            print("로그아웃 성공")
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Context 저장 실패: \(error.localizedDescription)")
        }
    }
}
