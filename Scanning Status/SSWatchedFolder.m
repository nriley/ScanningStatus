#import "SSWatchedFolder.h"
#import "SSAppDelegate.h"
#import "SSScannedDocument.h"

@interface SSWatchedFolder ()
+ (void)deduplicate:(NSArray *)documentIDs;
@end

@implementation SSWatchedFolder

- (void)awakeFromFetch;
{
	[super awakeFromFetch];
	[self updateFromDisk];
}

- (void)prepareForDeletion;
{
	[[NSApp delegate] watchedFolderListChanged];
}

// XXX implement as combination of awakeFromFetch / prepareForDeletion
// - (void)awakeFromSnapshotEvents:(NSSnapshotEventType)flags;

#pragma mark accessing

- (void)setIsExpanded:(NSNumber *)isExpanded;
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSUndoManager *undoManager = [moc undoManager];
	
	[moc processPendingChanges];
	[undoManager disableUndoRegistration];
	
	[self willChangeValueForKey:SSWatchedFolderAttributes.isExpanded];
	[self setPrimitiveIsExpanded:isExpanded];
	[self didChangeValueForKey:SSWatchedFolderAttributes.isExpanded];
	
	[moc processPendingChanges];
	[undoManager enableUndoRegistration];
}

- (void)setFileReferenceURL:(NSURL *)url;
{
	NSURL *fileReferenceURL = [url fileReferenceURL];
								  
	[self willChangeValueForKey:SSTreeNodeAttributes.fileReferenceURL];
	[self setPrimitiveFileReferenceURL:fileReferenceURL]; // XXX keyPathsForValuesAffectingValueForKey:?
	[self didChangeValueForKey:SSTreeNodeAttributes.fileReferenceURL];
	
	if (!fileReferenceURL)
		return;
	
	NSError *error;
	NSNumber *booleanValue;
	
	if (![fileReferenceURL getResourceValue:&booleanValue forKey:NSURLIsDirectoryKey error:&error])
		goto fail;
	if (![booleanValue boolValue])
		goto fail;
	
	if (![fileReferenceURL getResourceValue:&booleanValue forKey:NSURLIsPackageKey error:&error])
		goto fail;
	if ([booleanValue boolValue])
		goto fail;
	
	if (![self updateBookmark])
		goto fail;

	if (!self.name) {
		NSString *name;
		if (![fileReferenceURL getResourceValue:&name forKey:NSURLLocalizedNameKey error:&error])
			goto fail;
		
		self.name = name;
	}
	
	return;
	
fail:
	self.fileReferenceURL = nil;
}

- (BOOL)isLeaf;
{
	return NO;
}

- (NSString *)displayName;
{
	return self.name;
}

- (void)setDisplayName:(NSString *)displayName;
{
	self.name = displayName;
}

- (NSNumber *)pageCount;
{
	return nil;
}

#pragma mark actions

// XXX move this and deduplicate: into background queues
- (void)updateFromDisk;
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSUndoManager *undoManager = [moc undoManager];
	
	[moc processPendingChanges];
	[undoManager disableUndoRegistration];

	BOOL bookmarkDataIsStale;
	
	NSError *error;
	NSURL *folderURL = [NSURL URLByResolvingBookmarkData:self.bookmark options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:&error];
	
	if (!folderURL) { // folder disappeared
		NSLog(@"Can't resolve watched folder bookmark '%@': %@", self.name, error);
		
		if (self.modificationDate != nil) { // first time we noticed
			NSDate *date = [NSDate date];
			self.modificationDate = nil;
			[self.documents setValue:date forKey:SSScannedDocumentAttributes.removalDate];
			[self.documents setValue:date forKey:SSTreeNodeAttributes.modificationDate];
		}
		
		return;
	}
	NSLog(@"updating %@", [folderURL filePathURL]);

	self.fileReferenceURL = folderURL;
	
	if (bookmarkDataIsStale)
		[self updateBookmark];
	
	NSMutableSet *documentsSet = [self documentsSet];
	NSMapTable *documentByFilename = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaqueMemory valueOptions:NSPointerFunctionsOpaqueMemory capacity:[documentsSet count]];
	
	for (SSScannedDocument *document in documentsSet)
		NSMapInsert(documentByFilename, document.filename, document);
	
	NSMutableArray *documentsToAdd = [[NSMutableArray alloc] init];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:self.fileReferenceURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLLocalizedNameKey, NSURLIsRegularFileKey, NSURLContentModificationDateKey, NSURLTypeIdentifierKey, nil] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^(NSURL *url, NSError *error) { return YES; }];
	
    NSAutoreleasePool* localPool = [[NSAutoreleasePool alloc] init];
	int urlIndex = 1;
	for (NSURL *url in directoryEnumerator) {
		NSNumber *isRegularFile;
		if (![url getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:NULL])
			continue;
		if (![isRegularFile boolValue])
			continue;
		
		NSNumber *typeIdentifier;
		if (![url getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:NULL])
			continue;
		if (!UTTypeConformsTo((CFStringRef)typeIdentifier, kUTTypePDF))
			continue;
		
		NSString *filename;
		if (![url getResourceValue:&filename forKey:NSURLNameKey error:NULL])
			continue;
		
		NSString *localizedName;
		if (![url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL])
			continue;
		
		NSDate *modificationDate;
		if (![url getResourceValue:&modificationDate forKey:NSURLContentModificationDateKey error:NULL])
			continue;

		NSURL *fileReferenceURL = [url fileReferenceURL];

		SSScannedDocument *document = NSMapGet(documentByFilename, filename);
		if (document) {
			NSMapRemove(documentByFilename, filename);
			document.fileReferenceURL = fileReferenceURL;
			if (![modificationDate isEqualToDate:document.modificationDate]) {
				document.modificationDate = modificationDate;
				[document updatePageCount];
			}
		} else {
			document = [SSScannedDocument insertInManagedObjectContext:moc];
			document.filename = filename;
			document.modificationDate = modificationDate;
			document.fileReferenceURL = fileReferenceURL;
			[document updatePageCount];
			[document updateBookmark];
			[documentsToAdd addObject:document];
		}
		
		document.displayName = localizedName;
		
		if (urlIndex % 100 == 0) {
            [localPool drain];
            localPool = [[NSAutoreleasePool alloc] init];
        }
	}
	[localPool release];
	
	// documents not found in folder
	NSArray *orphanedDocuments = NSAllMapTableValues(documentByFilename);
	NSUInteger orphanedDocumentCount = [orphanedDocuments count];
	if (orphanedDocumentCount > 0) {
		NSMutableArray *orphanedDocumentIDs = [[NSMutableArray alloc] initWithCapacity:orphanedDocumentCount];
		orphanedDocumentCount = 0;
		for (SSScannedDocument *document in orphanedDocuments)
			if (![document isDeleted]) { // renamed in same folder
				[orphanedDocumentIDs addObject:[document objectID]];
				++orphanedDocumentCount;
			}
		
		if (orphanedDocumentCount > 0) {
			NSLog(@"%@ scheduling deduplication on %lu files", self.name, orphanedDocumentCount);
			NSInvocationOperation *deduplicationOperation = [[NSInvocationOperation alloc] initWithTarget:[self class] selector:@selector(deduplicate:) object:orphanedDocumentIDs];
			[[NSOperationQueue mainQueue] addOperation:deduplicationOperation];
			[deduplicationOperation release];
		}

		[orphanedDocumentIDs release];
	}

	[[self documentsSet] addObjectsFromArray:documentsToAdd];
	[documentsToAdd release];
	[documentByFilename release];
	
	[moc processPendingChanges];
	[undoManager enableUndoRegistration];
}

+ (void)deduplicate:(NSArray *)documentIDs;
{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//
//	NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
//	[moc setPersistentStoreCoordinator:[[NSApp delegate] persistentStoreCoordinator]];

	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	NSUndoManager *undoManager = [moc undoManager];
	
	[moc processPendingChanges];
	[undoManager disableUndoRegistration];

	NSLog(@"deduplicate: %@", documentIDs);
	
	for (SSScannedDocumentID *documentID in documentIDs) {
		SSScannedDocument *document = (SSScannedDocument *)[moc existingObjectWithID:documentID error:NULL];
		
		if (document == nil || [document isDeleted])
			continue;
		
		// 0. In -updateFromDisk, we've already established that the file reference is no longer valid;
		//    so we try to locate the file in a few more ways before giving up
		// 1. Check that we haven't found the object in the meantime (i.e., URL is valid)
				
		// 2. Look for the filename in another folder
		SSScannedDocument *sameNamedDocument = [SSScannedDocument scannedDocumentWithFilename:document.filename inManagedObjectContext:moc];
		if (sameNamedDocument != nil && sameNamedDocument != document) {
			NSLog(@"found '%@' elsewhere by filename", document.filename);
			[document removeFromFolder];
			continue;
		}
		
		// 3. Try to resolve the bookmark
		BOOL bookmarkDataIsStale;
		NSError *error;
		NSURL *fileURL = [NSURL URLByResolvingBookmarkData:document.bookmark options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:&error];

		if (bookmarkDataIsStale)
			[document updateBookmark];
		
		if (fileURL) {
			NSURL *fileReferenceURL = [fileURL fileReferenceURL];
			SSScannedDocument *otherDocument = [SSScannedDocument scannedDocumentWithFileReferenceURL:fileReferenceURL inManagedObjectContext:moc];
			if (otherDocument != nil && otherDocument != document) {
				NSLog(@"found '%@' elsewhere by bookmark", document.filename);
				[document removeFromFolder];
				continue;
			}
		}
		
		// 4. Set the removal date
		document.removalDate = [NSDate date];
		document.fileReferenceURL = nil;
		document.displayName = document.filename; // XXX fix when display name persists
	}
	
	// XXX once concurrent, save and notify main thread (mergeChangesFromContextDidSaveNotification:)
	// -- or can we propagate changes without saving? that'd be nicer.
	
//	[moc release];
//	[pool release];

	[moc processPendingChanges];
	[undoManager enableUndoRegistration];
}

@end
