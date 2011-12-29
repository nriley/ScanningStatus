// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SSTreeNode.h instead.

#import <CoreData/CoreData.h>


extern const struct SSTreeNodeAttributes {
	 NSString *bookmark;
	 NSString *displayName;
	 NSString *fileReferenceURL;
	 NSString *modificationDate;
} SSTreeNodeAttributes;

extern const struct SSTreeNodeRelationships {
} SSTreeNodeRelationships;

extern const struct SSTreeNodeFetchedProperties {
} SSTreeNodeFetchedProperties;




@class NSURL;


@interface SSTreeNodeID : NSManagedObjectID {}
@end

@interface _SSTreeNode : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SSTreeNodeID*)objectID;




@property (nonatomic, retain) NSData *bookmark;


//- (BOOL)validateBookmark:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *displayName;


//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSURL *fileReferenceURL;


//- (BOOL)validateFileReferenceURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *modificationDate;


//- (BOOL)validateModificationDate:(id*)value_ error:(NSError**)error_;





@end

@interface _SSTreeNode (CoreDataGeneratedAccessors)

@end

@interface _SSTreeNode (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveBookmark;
- (void)setPrimitiveBookmark:(NSData*)value;




- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSURL*)primitiveFileReferenceURL;
- (void)setPrimitiveFileReferenceURL:(NSURL*)value;




- (NSDate*)primitiveModificationDate;
- (void)setPrimitiveModificationDate:(NSDate*)value;




@end
