// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Collection.swift instead.

import CoreData

enum CollectionAttributes: String {
    case collectionId = "collectionId"
    case copyright = "copyright"
    case englishName = "englishName"
    case position = "position"
    case version = "version"
}

enum CollectionRelationships: String {
    case books = "books"
    case language = "language"
}

@objc
class _Collection: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Collection"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Collection.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var collectionId: String

    // func validateCollectionId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var copyright: String?

    // func validateCopyright(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var englishName: String

    // func validateEnglishName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var position: NSNumber?

    // func validatePosition(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var version: String?

    // func validateVersion(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var books: NSOrderedSet

    @NSManaged
    var language: Language?

    // func validateLanguage(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

extension _Collection {

    func addBooks(objects: NSOrderedSet) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func removeBooks(objects: NSOrderedSet) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func addBooksObject(value: Book!) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.books = mutable.copy() as! NSOrderedSet
    }

    func removeBooksObject(value: Book!) {
        let mutable = self.books.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.books = mutable.copy() as! NSOrderedSet
    }

}
