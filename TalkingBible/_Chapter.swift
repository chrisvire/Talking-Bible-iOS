// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Chapter.swift instead.

import CoreData

enum ChapterAttributes: String {
    case englishName = "englishName"
    case mp3 = "mp3"
    case position = "position"
}

enum ChapterRelationships: String {
    case book = "book"
}

@objc
class _Chapter: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Chapter"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Chapter.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var englishName: String

    // func validateEnglishName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var mp3: String

    // func validateMp3(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var position: NSNumber?

    // func validatePosition(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var book: Book?

    // func validateBook(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

