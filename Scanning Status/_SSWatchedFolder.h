// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SSWatchedFolder.h instead.

#import <CoreData/CoreData.h>
#import "SSTreeNode.h"

extern const struct SSWatchedFolderAttributes {
	 NSString *isExpanded;
	 NSString *name;
	 NSString *persistAfterRemoval;
} SSWatchedFolderAttributes;

extern const struct SSWatchedFolderRelationships {
	 NSString *documents;
} SSWatchedFolderRelationships;

extern const struct SSWatchedFolderFetchedProperties {
} SSWatchedFolderFetchedProperties;

@class SSScannedDocument;





@interface SSWatchedFolderID : NSManagedObjectID {}
@end

@interface _SSWatchedFolder : SSTreeNode {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SSWatchedFolderID*)objectID;




@property (nonatomic, retain) NSNumber *isExpanded;


@property BOOL isExpandedValue;
- (BOOL)isExpandedValue;
- (void)setIsExpandedValue:(BOOL)value_;

//- (BOOL)validateIsExpanded:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *persistAfterRemoval;


@property BOOL persistAfterRemovalValue;
- (BOOL)persistAfterRemovalValue;
- (void)setPersistAfterRemovalValue:(BOOL)value_;

//- (BOOL)validatePersistAfterRemoval:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet* documents;

- (NSMutableSet*)documentsSet;




@end

@interface _SSWatchedFolder (CoreDataGeneratedAccessors)

- (void)addDocuments:(NSSet*)value_;
- (void)removeDocuments:(NSSet*)value_;
- (void)addDocumentsObject:(SSScannedDocument*)value_;
- (void)removeDocumentsObject:(SSScannedDocument*)value_;

@end

@interface _SSWatchedFolder (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsExpanded;
- (void)setPrimitiveIsExpanded:(NSNumber*)value;

- (BOOL)primitiveIsExpandedValue;
- (void)setPrimitiveIsExpandedValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePersistAfterRemoval;
- (void)setPrimitivePersistAfterRemoval:(NSNumber*)value;

- (BOOL)primitivePersistAfterRemovalValue;
- (void)setPrimitivePersistAfterRemovalValue:(BOOL)value_;





- (NSMutableSet*)primitiveDocuments;
- (void)setPrimitiveDocuments:(NSMutableSet*)value;


@end
