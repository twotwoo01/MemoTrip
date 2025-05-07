//
//  MemoWriteView.swift
//  MemoTrip
//
//  Created by 조수원 on 4/29/25.
//

import SwiftUI
import PhotosUI
import CoreData

struct MemoWriteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var recognizer = SpeechRecognizer()

    @State private var content: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil

    @State private var loading = false
    @State private var alanMessage: String = ""

    let statusSteps = [
        "답변해주러 사무실로 가는 중...",
        "컴퓨터 키는 중...",
        "찾아보는 중...",
        "답변 정리 중...",
        "답변 정리 완료!!!",
        "타이핑 치는 중..."
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 📷 사진 업로드
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        ZStack {
                            if let imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 250)
                                    .overlay(Text("사진 선택").foregroundColor(.gray))
                            }
                        }
                    }
                    TextEditor(text: $content)
                        .frame(height: 150)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    if !recognizer.transcript.isEmpty {
                        Text("인식된 텍스트: \(recognizer.transcript)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    if loading {
                        VStack(spacing: 8) {
                            Image(systemName: "cellularbars")
                                .symbolEffect(.variableColor)
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                            Text(alanMessage)
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                    VStack(spacing: 12) {
                        HStack {
                            Button("말하기") {
                                recognizer.start()
                            }
                            .buttonStyle(.bordered)

                            Button("메모에 추가") {
                                recognizer.stop()
                                content += "\n" + recognizer.transcript
                            }
                            .buttonStyle(.bordered)
                        }

                        Button("Alan에게 요약 요청") {
                            sendToAlanSummary()
                        }
                        .buttonStyle(.bordered)

                        Button("저장") {
                            saveMemo()
                            dismiss()
                        }
                        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("일기 작성")
            .onChange(of: selectedImage) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }

    private func saveMemo() {
        let newMemo = Memo(context: viewContext)
        newMemo.id = UUID()
        newMemo.date = Date()
        newMemo.content = content
        newMemo.image = imageData

        do {
            try viewContext.save()
            print("저장 성공")
        } catch {
            print("저장 실패: \(error.localizedDescription)")
        }
    }

    private func sendToAlanSummary() {
        loading = true
        alanMessage = statusSteps[0]

        for i in 1..<statusSteps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i * 3)) {
                alanMessage = statusSteps[i]
            }
        }

        AlanService.shared.summarizeMemo(content: content) { reply in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(statusSteps.count * 3)) {
                if let summary = reply {
                    content += "\n\nAlan 요약:\n\(summary)"
                } else {
                    content += "\n\nAlan 요약: (응답 오류)"
                }
                loading = false
                alanMessage = ""
            }
        }
    }
}
#Preview {
    MemoWriteView()
}
