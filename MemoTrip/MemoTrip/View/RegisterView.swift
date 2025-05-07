//
//  RegisterView.swift
//  MemoTrip
//
//  Created by 조수원 on 4/28/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var registerVM = RegisterViewModel()

    @State private var email = ""
    @State private var password = ""
    @State private var securePassword = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack {
                    Text("MemoTrip")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .padding(30)
                    
                    Text("회원가입")
                        .font(.title.bold())
                        .padding(.bottom, 60)

                    VStack(spacing: 20) {
                        TextField("이메일을 입력해주세요", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        HStack {
                            if securePassword {
                                TextField("비밀번호", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                SecureField("비밀번호", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            Button {
                                securePassword.toggle()
                            } label: {
                                Image(systemName: securePassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)

                    if !registerVM.errorMessage.isEmpty {
                        Text(registerVM.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button {
                        Task {
                            await registerVM.register(email: email, password: password)
                        }
                    } label: {
                        Text("가입하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 110, height: 45)
                            .background(Color.gray)
                            .cornerRadius(20)
                            .offset(x: 0, y: 30)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
            .onChange(of: registerVM.registerLogin) {
                if registerVM.registerLogin {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
