import Foundation
import RealmSwift

enum Mood: String, PersistableEnum, CaseIterable {
    case great, good, okay, bad, aweful
    
    var emojii: String {
        switch self {
            
        case .great:
            return "😃"
        case .good:
            return "🙂"
        case .okay:
            return "😕"
        case .bad:
            return "☹️"
        case .aweful:
            return "😖"
        }
    }
}

class MoodRealmEntry: Object {
    @Persisted(primaryKey: true) var id = ObjectId.generate()
    @Persisted var mood: Mood
    @Persisted var notes: String
    @Persisted var createdAt: Date

    convenience init(moodEntry: MoodEntry) {
        self.init()
        self.mood = moodEntry.mood
        self.notes = moodEntry.notes
        self.createdAt = moodEntry.createdAt
    }

    func toMoodEntry() -> MoodEntry {
        MoodEntry(mood: self.mood, notes: self.notes, createdAt: self.createdAt)
    }
}

struct MoodEntry: Hashable {
    let mood: Mood
    let notes: String
    let createdAt: Date
}
