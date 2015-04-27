// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Language.swift instead.

import CoreData

enum LanguageAttributes: String {
    case englishName = "englishName"
    case languageId = "languageId"
}

enum LanguageRelationships: String {
    case collections = "collections"
}

@objc
class _Language: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Language"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Language.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var englishName: String

    // func validateEnglishName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var languageId: String

    // func validateLanguageId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var collections: NSOrderedSet

}

extension _Language {

    func addCollections(objects: NSOrderedSet) {
        let mutable = self.collections.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.collections = mutable.copy() as! NSOrderedSet
    }

    func removeCollections(objects: NSOrderedSet) {
        let mutable = self.collections.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.collections = mutable.copy() as! NSOrderedSet
    }

    func addCollectionsObject(value: Collection!) {
        let mutable = self.collections.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.collections = mutable.copy() as! NSOrderedSet
    }

    func removeCollectionsObject(value: Collection!) {
        let mutable = self.collections.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.collections = mutable.copy() as! NSOrderedSet
    }

}
