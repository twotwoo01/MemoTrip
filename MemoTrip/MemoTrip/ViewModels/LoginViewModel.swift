//
//  LoginViewModel.swift
//  MemoTrip
//
//  Created by 조수원 on 4/28/25.
//

import Foundation
import CoreData

@MainActor
class LoginViewModel: ObservableObject {
    @Published var login = false
    @Published var errorMessage: String = ""
    
    let context = PersistenceController.shared.container.viewContext
    
    func login(email: String, password: String) async {
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(request)
            
            if let user = users.first {
                if user.password == password {
                    print("로그인 성공")
                    login = true
                    errorMessage = ""
                } else {
                    print("비밀번호 틀림")
                    login = false
                    errorMessage = "비밀번호가 틀렸습니다. 비밀번호를 다시 확인해주세요."
                }
            } else {
                print("해당 이메일 없음")
                login = false
                errorMessage = "가입되지 않은 계정입니다. 회원가입 후 이용해주세요."
            }

        } catch {
            print("로그인 실패: \(error.localizedDescription)")
            login = false
            errorMessage = "로그인 중 오류가 발생했습니다."
        }
    }
}
