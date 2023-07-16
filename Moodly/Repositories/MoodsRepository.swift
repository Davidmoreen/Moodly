import Foundation
import Combine
import RealmSwift

protocol MoodsRepositoryProtocol {
    func getMoods() -> AnyPublisher<[MoodEntry], Error>
    func saveMood(entry: MoodEntry) -> AnyPublisher<(), Error>
}

class MoodsRealmRepository: MoodsRepositoryProtocol {
    let realm: Realm!
    
    init() {
        self.realm = try! Realm()
    }

    func getMoods() -> AnyPublisher<[MoodEntry], Error> {
        return self.realm.objects(MoodRealmEntry.self)
            .collectionPublisher
            .map { results in
                Array(results).map { $0.toMoodEntry() }
            }
            .eraseToAnyPublisher()
    }
    
    func saveMood(entry: MoodEntry) -> AnyPublisher<(), Error> {
        return Future<(), Error> { promise in
            do {
                let record = MoodRealmEntry(moodEntry: entry)
                try self.realm.write {
                    self.realm.add(record)
                    promise(.success(()))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

class FakeMoodsRepository: MoodsRepositoryProtocol {
    func getMoods() -> AnyPublisher<[MoodEntry], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveMood(entry: MoodEntry) -> AnyPublisher<(), Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
