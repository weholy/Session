import Foundation

struct GroqMessage: Codable, Sendable {
    let role: String
    let content: String

    static func system(_ text: String) -> GroqMessage { .init(role: "system", content: text) }
    static func user(_ text: String) -> GroqMessage { .init(role: "user", content: text) }
    static func assistant(_ text: String) -> GroqMessage { .init(role: "assistant", content: text) }
}

enum GroqError: Error {
    case missingKey
    case transport(String)
    case badStatus(Int, String)
    case emptyResponse
    case decoding(String)
}

struct GroqClient: Sendable {
    var apiKey: String?
    var session: URLSession = .shared
    var timeout: TimeInterval = 45

    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    func complete(
        model: GroqModel,
        messages: [GroqMessage],
        json: Bool = false,
        temperature: Double = 0.4,
        maxTokens: Int = 2048,
        reasoning: GroqReasoning = .medium
    ) async throws -> String {
        guard let apiKey, !apiKey.isEmpty else { throw GroqError.missingKey }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        var payload: [String: Any] = [
            "model": model.rawValue,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "temperature": temperature,
            "max_completion_tokens": maxTokens,
            "reasoning_effort": reasoning.rawValue
        ]
        if json {
            payload["response_format"] = ["type": "json_object"]
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw GroqError.transport(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else { throw GroqError.emptyResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw GroqError.badStatus(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = root["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String,
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GroqError.emptyResponse
        }

        return content
    }

    func decodeJSON<T: Decodable>(_ type: T.Type, from raw: String) throws -> T {
        let cleaned = Self.stripFences(raw)
        guard let data = cleaned.data(using: .utf8) else {
            throw GroqError.decoding("не удалось прочитать ответ")
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw GroqError.decoding(String(describing: error))
        }
    }

    private static func stripFences(_ text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("```") {
            if let firstNewline = s.firstIndex(of: "\n") {
                s = String(s[s.index(after: firstNewline)...])
            }
            if let fence = s.range(of: "```", options: .backwards) {
                s = String(s[..<fence.lowerBound])
            }
        }
        if let start = s.firstIndex(where: { $0 == "{" || $0 == "[" }),
           let end = s.lastIndex(where: { $0 == "}" || $0 == "]" }) {
            s = String(s[start...end])
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
