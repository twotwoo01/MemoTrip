//
//  HomeView.swift
//  MemoTrip
//
//  Created by 조수원 on 4/28/25.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Memo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Memo.date, ascending: false)]
    ) private var memos: FetchedResults<Memo>

    @State private var selectedMemoID: UUID? = nil
    @State private var memoWrite = false
    @State private var selectedDate = Date()
    @State private var memoDelete: Memo? = nil
    @State private var deleteAlert = false

    var groupedMemos: [String: [Memo]] {
        Dictionary(grouping: memos) { memo in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: memo.date ?? Date())
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(groupedMemos.sorted(by: { $0.key > $1.key }), id: \.key) { dateString, memosForDate in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(dateString)
                                .font(.title2.bold())
                                .padding(.horizontal)

                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 16) {
                                    ForEach(memosForDate, id: \.self) { memo in
                                        memoCard(memo)
                                            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .scrollTransition { content, phase in
                                                content
                                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                                    .opacity(phase.isIdentity ? 1.0 : 0.6)
                                            }
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    memoDelete = memo
                                                    deleteAlert = true
                                                } label: {
                                                    Label("삭제", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .scrollPosition(id: $selectedMemoID)
                            .scrollIndicators(.hidden)
                            .safeAreaPadding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("일기")
            .toolbar {
                Button {
                    memoWrite = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $memoWrite) {
                MemoWriteView()
            }
            .alert("메모를 삭제하시겠습니까?", isPresented: $deleteAlert, presenting: memoDelete) { memo in
                Button("삭제", role: .destructive) {
                    deleteMemo(memo)
                }
                Button("취소", role: .cancel) { }
            }
        }
    }

    private func memoCard(_ memo: Memo) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let imageData = memo.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 250)
            }

            if let content = memo.content {
                Text(content)
                    .padding()
                    .foregroundColor(.white)
                    .font(.caption)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .padding([.leading, .bottom], 10)
            }
        }
        .frame(width: 300)
        .onTapGesture {
            selectedMemoID = memo.id
        }
    }

    private func deleteMemo(_ memo: Memo) {
        viewContext.delete(memo)
        do {
            try viewContext.save()
        } catch {
            print("메모 삭제 실패: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
