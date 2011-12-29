#import "SSTreeNode.h"

@implementation SSTreeNode

- (void)awakeFromInsert;
{
	[super awakeFromInsert];
	self.modificationDate = [NSDate date];
}

- (BOOL)isDeletable;
{
	return (![self isLeaf] || self.fileReferenceURL == nil);
}

- (NSString *)path;
{
	return [[self.fileReferenceURL filePathURL] path];
}

- (NSString *)displayPath;
{
	return [[[NSFileManager defaultManager] componentsToDisplayForPath:[self path]] componentsJoinedByString: @" \u25b8 "];
}

- (BOOL)updateBookmark;
{
	NSURL *url = self.fileReferenceURL;
	if (!url)
		return false;
	
	NSError *error;
	NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationPreferFileIDResolution includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
	if (bookmark == nil) {
		NSLog(@"bookmark creation for %@ failed: %@", self, error);
		return false;
	}
	self.bookmark = bookmark; // don't overwrite with nil
	return true;
}

#pragma mark subclass responsibility

- (BOOL)isLeaf;
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (NSString *)displayName;
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSNumber *)pageCount;
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark QLPreviewItem

- (NSURL *)previewItemURL;
{
	return self.fileReferenceURL;
}

@end
