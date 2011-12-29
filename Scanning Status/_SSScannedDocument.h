// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SSScannedDocument.h instead.

#import <CoreData/CoreData.h>
#import "SSTreeNode.h"

extern const struct SSScannedDocumentAttributes {
	 NSString *filename;
	 NSString *pageCount;
	 NSString *removalDate;
} SSScannedDocumentAttributes;

extern const struct SSScannedDocumentRelationships {
	 NSString *folder;
} SSScannedDocumentRelationships;

extern const struct SSScannedDocumentFetchedProperties {
} SSScannedDocumentFetchedProperties;

@class SSWatchedFolder;





@interface SSScannedDocumentID : NSManagedObjectID {}
@end

@interface _SSScannedDocument : SSTreeNode {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SSScannedDocumentID*)objectID;




@property (nonatomic, retain) NSString *filename;


//- (BOOL)validateFilename:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *pageCount;


@property int pageCountValue;
- (int)pageCountValue;
- (void)setPageCountValue:(int)value_;

//- (BOOL)validatePageCount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *removalDate;


//- (BOOL)validateRemovalDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) SSWatchedFolder* folder;

//- (BOOL)validateFolder:(id*)value_ error:(NSError**)error_;




@end

@interface _SSScannedDocument (CoreDataGeneratedAccessors)

@end

@interface _SSScannedDocument (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFilename;
- (void)setPrimitiveFilename:(NSString*)value;




- (NSNumber*)primitivePageCount;
- (void)setPrimitivePageCount:(NSNumber*)value;

- (int)primitivePageCountValue;
- (void)setPrimitivePageCountValue:(int)value_;




- (NSDate*)primitiveRemovalDate;
- (void)setPrimitiveRemovalDate:(NSDate*)value;





- (SSWatchedFolder*)primitiveFolder;
- (void)setPrimitiveFolder:(SSWatchedFolder*)value;


@end
