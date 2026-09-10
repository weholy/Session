import Foundation

enum GroqModel: String {
    case planning = "openai/gpt-oss-120b"
    case conversation = "openai/gpt-oss-20b"
}

enum GroqReasoning: String {
    case low
    case medium
    case high
}
