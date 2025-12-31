import Foundation
import CoreData

actor SubscriptionStore {
    static let shared = SubscriptionStore()
    private let container: NSPersistentContainer
    private let legacyFileURL: URL

    init() {
        let modelURL = Bundle.main.url(forResource: "SubTracker", withExtension: "momd")
        if let modelURL, let model = NSManagedObjectModel(contentsOf: modelURL) {
            container = NSPersistentContainer(name: "SubTracker", managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: "SubTracker")
        }
        container.loadPersistentStores { _, error in
            if let error {
                print("Persistent store error: \(error)")
            }
        }

        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        if !fm.fileExists(atPath: base.path) {
            try? fm.createDirectory(at: base, withIntermediateDirectories: true)
        }
        legacyFileURL = base.appendingPathComponent("subscriptions.json")
    }

    func load() -> [Subscription] {
        var results: [Subscription] = []
        let context = container.viewContext
        context.performAndWait {
            let request: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
            if let fetched = try? context.fetch(request) {
                results = fetched.map { $0.toSubscription() }
            }
        }
        if results.isEmpty {
            results = migrateLegacyIfNeeded()
        }
        return results
    }

    func save(_ subscriptions: [Subscription]) async {
        let context = container.viewContext
        await context.perform {
            let request: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
            let existing = (try? context.fetch(request)) ?? []
            var map = [UUID: SubscriptionEntity]()
            existing.forEach { if let id = $0.id { map[id] = $0 } }

            let incomingIDs = Set(subscriptions.map { $0.id })

            for sub in subscriptions {
                let entity = map[sub.id] ?? SubscriptionEntity(context: context)
                entity.id = sub.id
                entity.name = sub.name
                entity.amount = sub.amount
                entity.currency = sub.currency
                entity.nextRenewal = sub.nextRenewal
                entity.endDate = sub.endDate
                entity.cycle = sub.cycle.rawValue
                entity.category = sub.category.rawValue
            }

            // delete removed
            for (id, entity) in map where !incomingIDs.contains(id) {
                context.delete(entity)
            }

            try? context.save()
        }
    }

    private func migrateLegacyIfNeeded() -> [Subscription] {
        guard let data = try? Data(contentsOf: legacyFileURL),
              let decoded = try? JSONDecoder().decode([Subscription].self, from: data) else { return [] }
        Task { await save(decoded) }
        return decoded
    }
}
