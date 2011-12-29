// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SSWatchedFolder.m instead.

#import "_SSWatchedFolder.h"

const struct SSWatchedFolderAttributes SSWatchedFolderAttributes = {
	.isExpanded = @"isExpanded",
	.name = @"name",
	.persistAfterRemoval = @"persistAfterRemoval",
};

const struct SSWatchedFolderRelationships SSWatchedFolderRelationships = {
	.documents = @"documents",
};

const struct SSWatchedFolderFetchedProperties SSWatchedFolderFetchedProperties = {
};

@implementation SSWatchedFolderID
@end

@implementation _SSWatchedFolder

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WatchedFolder" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WatchedFolder";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WatchedFolder" inManagedObjectContext:moc_];
}

- (SSWatchedFolderID*)objectID {
	return (SSWatchedFolderID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isExpandedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isExpanded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"persistAfterRemovalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"persistAfterRemoval"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic isExpanded;



- (BOOL)isExpandedValue {
	NSNumber *result = [self isExpanded];
	return [result boolValue];
}

- (void)setIsExpandedValue:(BOOL)value_ {
	[self setIsExpanded:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsExpandedValue {
	NSNumber *result = [self primitiveIsExpanded];
	return [result boolValue];
}

- (void)setPrimitiveIsExpandedValue:(BOOL)value_ {
	[self setPrimitiveIsExpanded:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic persistAfterRemoval;



- (BOOL)persistAfterRemovalValue {
	NSNumber *result = [self persistAfterRemoval];
	return [result boolValue];
}

- (void)setPersistAfterRemovalValue:(BOOL)value_ {
	[self setPersistAfterRemoval:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePersistAfterRemovalValue {
	NSNumber *result = [self primitivePersistAfterRemoval];
	return [result boolValue];
}

- (void)setPrimitivePersistAfterRemovalValue:(BOOL)value_ {
	[self setPrimitivePersistAfterRemoval:[NSNumber numberWithBool:value_]];
}





@dynamic documents;

	
- (NSMutableSet*)documentsSet {
	[self willAccessValueForKey:@"documents"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"documents"];
  
	[self didAccessValueForKey:@"documents"];
	return result;
}
	





@end
