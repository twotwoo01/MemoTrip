//
//  SettingsView.swift
//  MemoTrip
//
//  Created by 조수원 on 4/29/25.
//


import SwiftUI
import PhotosUI

struct SettingsView: View {
    @AppStorage("login") private var login: Bool = true
    @StateObject private var settingsVM = SettingsViewModel()

    @State private var selectedPhoto: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack {
                    if let image = settingsVM.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Text("프로필 사진 변경")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .onChange(of: selectedPhoto) {
                        Task {
                            if let selectedPhoto,
                               let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                settingsVM.updateProfileImage(image: uiImage)
                            }
                        }
                    }

                    Text(settingsVM.userEmail)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                }

                Spacer()

                Button(role: .destructive) {
                    settingsVM.logout()
                } label: {
                    Text("로그아웃")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color.red)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: settingsVM.isLoggedOut) { _, loggedOut in
                if loggedOut {
                    login = false
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
