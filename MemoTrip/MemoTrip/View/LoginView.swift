//
//  LoginView.swift
//  MemoTrip
//
//  Created by 조수원 on 4/28/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var loginVM = LoginViewModel()
    @AppStorage("isLogin") private var isLogin = false

    @State private var loginClick = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var securePassword = false
    @State private var errorText = false

    var body: some View {
        NavigationStack {
            if isLogin {
                HomeView()
            } else {
                loginContent
            }
        }
    }

    private var loginContent: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                Text("Memo\n          Trip")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .scaleEffect(loginClick ? 1.5 : 1)
                    .padding(30)

                Image(systemName:"camera.badge.clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 130)
                    .scaleEffect(loginClick ? 1.5 : 1)
                    .padding(.bottom, loginClick ? 40 : 80)

                if loginClick {
                    VStack(spacing: 16) {
                        TextField("아이디를 입력해주세요.", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        HStack {
                            if securePassword {
                                TextField("비밀번호를 입력해주세요.", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                SecureField("비밀번호를 입력해주세요.", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            Button {
                                securePassword.toggle()
                            } label: {
                                Image(systemName: securePassword ? "eye.slash" : "eye")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)

                        if !loginVM.errorMessage.isEmpty {
                            Text(loginVM.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .rotationEffect(.degrees(errorText ? 3 : 0))
                                .animation(.easeInOut(duration: 0.05).repeatCount(3, autoreverses: true), value: errorText)
                        }

                        Button {
                            loginButtonTapped()
                        } label: {
                            Text("로그인")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color.gray)
                                .cornerRadius(20)
                        }
                        NavigationLink("회원가입", destination: RegisterView())
                            .font(.caption)
                    }
                    .padding(.top, 10)
                } else {
                    Button {
                        withAnimation {
                            loginClick = true
                        }
                    } label: {
                        Text("로그인")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 40)
                            .background(Color.gray)
                            .cornerRadius(20)
                    }
                    .padding(.top, 30)
                }
            }
        }
    }

    private func loginButtonTapped() {
        if !loginEmail(email) {
            loginVM.errorMessage = "올바른 이메일 형식으로 입력해주세요."
            return
        }

        Task {
            await loginVM.login(email: email, password: password)

            if loginVM.login {
                withAnimation {
                    isLogin = true
                }
            } else {
                withAnimation {
                    errorText = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    errorText = false
                }
            }
        }
    }

    private func loginEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}

#Preview {
    LoginView()
}
