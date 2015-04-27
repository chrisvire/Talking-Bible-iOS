// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Book.swift instead.

import CoreData

enum BookAttributes: String {
    case bookId = "bookId"
    case englishName = "englishName"
    case position = "position"
}

enum BookRelationships: String {
    case chapters = "chapters"
    case collection = "collection"
}

@objc
class _Book: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Book"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Book.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var bookId: String

    // func validateBookId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var englishName: String

    // func validateEnglishName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var position: NSNumber?

    // func validatePosition(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var chapters: NSOrderedSet

    @NSManaged
    var collection: Collection?

    // func validateCollection(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Book {

    func addChapters(objects: NSOrderedSet) {
        let mutable = self.chapters.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.chapters = mutable.copy() as! NSOrderedSet
    }

    func removeChapters(objects: NSOrderedSet) {
        let mutable = self.chapters.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.chapters = mutable.copy() as! NSOrderedSet
    }

    func addChaptersObject(value: Chapter!) {
        let mutable = self.chapters.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.chapters = mutable.copy() as! NSOrderedSet
    }

    func removeChaptersObject(value: Chapter!) {
        let mutable = self.chapters.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.chapters = mutable.copy() as! NSOrderedSet
    }

}
