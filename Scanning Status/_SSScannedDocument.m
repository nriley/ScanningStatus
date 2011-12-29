// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SSScannedDocument.m instead.

#import "_SSScannedDocument.h"

const struct SSScannedDocumentAttributes SSScannedDocumentAttributes = {
	.filename = @"filename",
	.pageCount = @"pageCount",
	.removalDate = @"removalDate",
};

const struct SSScannedDocumentRelationships SSScannedDocumentRelationships = {
	.folder = @"folder",
};

const struct SSScannedDocumentFetchedProperties SSScannedDocumentFetchedProperties = {
};

@implementation SSScannedDocumentID
@end

@implementation _SSScannedDocument

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ScannedDocument" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ScannedDocument";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ScannedDocument" inManagedObjectContext:moc_];
}

- (SSScannedDocumentID*)objectID {
	return (SSScannedDocumentID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"pageCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"pageCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic filename;






@dynamic pageCount;



- (int)pageCountValue {
	NSNumber *result = [self pageCount];
	return [result intValue];
}

- (void)setPageCountValue:(int)value_ {
	[self setPageCount:[NSNumber numberWithInt:value_]];
}

- (int)primitivePageCountValue {
	NSNumber *result = [self primitivePageCount];
	return [result intValue];
}

- (void)setPrimitivePageCountValue:(int)value_ {
	[self setPrimitivePageCount:[NSNumber numberWithInt:value_]];
}





@dynamic removalDate;






@dynamic folder;

	





@end
