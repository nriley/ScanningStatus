// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SSTreeNode.m instead.

#import "_SSTreeNode.h"

const struct SSTreeNodeAttributes SSTreeNodeAttributes = {
	.bookmark = @"bookmark",
	.displayName = @"displayName",
	.fileReferenceURL = @"fileReferenceURL",
	.modificationDate = @"modificationDate",
};

const struct SSTreeNodeRelationships SSTreeNodeRelationships = {
};

const struct SSTreeNodeFetchedProperties SSTreeNodeFetchedProperties = {
};

@implementation SSTreeNodeID
@end

@implementation _SSTreeNode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TreeNode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TreeNode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TreeNode" inManagedObjectContext:moc_];
}

- (SSTreeNodeID*)objectID {
	return (SSTreeNodeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic bookmark;






@dynamic displayName;






@dynamic fileReferenceURL;






@dynamic modificationDate;










@end
