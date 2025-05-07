//
//  AlanService.swift
//  VoiceAppAlanKR
//
//  Created by 조수원 on 4/23/25.
//

import Foundation

class AlanService {
    static let shared = AlanService()

    private let apiKey = "9b61d371-495d-479e-9835-c04ede19bb2e"
    private let baseURL = "https://kdt-api-function.azurewebsites.net/api/v1/question"
    private let clientID = "9b61d371-495d-479e-9835-c04ede19bb2e"

    func sendCommand(_ userText: String, completion: @escaping (String?) -> Void) {
        guard let encoded = userText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?content=\(encoded)&client_id=\(clientID)") else {
            completion("API URL 오류")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 오류:", error.localizedDescription)
                completion("네트워크 오류: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("응답 데이터 없음")
                return
            }

            let raw = String(data: data, encoding: .utf8) ?? "디코딩 실패"
            print("Alan 응답 원문:", raw)

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? String {

                let sentences = content
                    .components(separatedBy: .newlines)
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty && !$0.contains("###") }
                
                let final = sentences.last ?? content
                completion(final)
            } else {
                completion("content 키 없음")
            }
        }.resume()
    }

    func summarizeMemo(content: String, completion: @escaping (String?) -> Void) {
        let prompt = """
        다음은 사용자의 일기입니다.

        내용: \(content.prefix(500)) // 너무 긴 요청 방지

        이 내용을 요약해주고, 감정이나 분위기, 기억에 남는 포인트를 간단하게 코멘트 해줘.
        """
        sendCommand(prompt, completion: completion)
    }
}
