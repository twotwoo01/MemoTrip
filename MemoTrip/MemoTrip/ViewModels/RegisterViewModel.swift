//
//  RegisterViewModel.swift
//  MemoTrip
//
//  Created by 조수원 on 4/28/25.
//

import Foundation
import CoreData

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var registerLogin = false
    @Published var errorMessage = ""

    let context = PersistenceController.shared.container.viewContext

    func register(email: String, password: String) async {
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요"
            return
        }

        guard emailCheck(email) else {
            errorMessage = "이메일 형식이 유효하지 않습니다"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "비밀번호를 입력해주세요"
            return
        }

        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let existingUsers = try context.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                errorMessage = "이미 가입된 이메일입니다"
                return
            }

            let newUser = User(context: context)
            newUser.email = email
            newUser.password = password

            try context.save()
            print("회원가입 성공. ID: \(email), PW: \(password)")
            registerLogin = true
        } catch {
            errorMessage = "회원가입 실패: \(error.localizedDescription)"
        }
    }

    private func emailCheck(_ str: String)  -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: str)
    }
}
