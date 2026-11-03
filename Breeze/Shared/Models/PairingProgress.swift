import Foundation

/// A deadline describes waiting time, not an invented percentage of completion.
struct PairingProgress: Sendable {
    private(set) var stage: PairingStage = .idle
    private(set) var detail = ""
    private(set) var deadline: Date?
    private(set) var events: [String] = []

    mutating func update(_ stage: PairingStage, detail: String, timeout: TimeInterval? = nil, now: Date = .now) {
        self.stage = stage
        self.detail = detail
        if let timeout { deadline = now.addingTimeInterval(timeout) }
        if [.idle, .complete, .failed, .cancelled].contains(stage) { deadline = nil }
        if events.last != stage.title { events.append(stage.title) }
    }

    func hasExpired(at date: Date) -> Bool {
        guard let deadline else { return false }
        return date >= deadline
    }

    func remainingSeconds(at date: Date) -> Int {
        guard let deadline else { return 0 }
        return max(0, Int(ceil(deadline.timeIntervalSince(date))))
    }
}
