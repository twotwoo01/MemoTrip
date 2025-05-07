//
//  HomeViewModel.swift
//  MemoTrip
//
//  Created by 조수원 on 4/29/25.
//

import Foundation
import CoreData

class MemoViewModel: ObservableObject {
    @Published var memos: [Memo] = []

    func deleteMemo(_ memo: Memo, context: NSManagedObjectContext) {
        context.delete(memo)
        do {
            try context.save()
        } catch {
            print("삭제 실패: \(error.localizedDescription)")
        }
    }
}
