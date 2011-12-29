#import "SSScannedDocument.h"
#import "SSWatchedFolder.h"

@implementation SSScannedDocument

static NSMutableDictionary *fileReferenceURLToDocumentID;
static NSMutableDictionary *filenameToDocumentID;

+ (void)initialize;
{
	if (fileReferenceURLToDocumentID != nil)
		return; // yes, this can execute more than once
	
	fileReferenceURLToDocumentID = [[NSMutableDictionary alloc] init];
	filenameToDocumentID = [[NSMutableDictionary alloc] init];
}

+ (SSScannedDocument *)scannedDocumentWithFileReferenceURL:(NSURL *)fileReferenceURL inManagedObjectContext:(NSManagedObjectContext *)moc;
{
	SSScannedDocumentID *documentID = [fileReferenceURLToDocumentID objectForKey:fileReferenceURL];
	if (!documentID)
		return nil;
	
	return (SSScannedDocument *)[moc existingObjectWithID:documentID error:NULL];
}

+ (SSScannedDocument *)scannedDocumentWithFilename:(NSString *)filename inManagedObjectContext:(NSManagedObjectContext *)moc;
{
	SSScannedDocumentID *documentID = [filenameToDocumentID objectForKey:filename];
	if (!documentID)
		return nil;
	
	return (SSScannedDocument *)[moc existingObjectWithID:documentID error:NULL];
}


- (BOOL)isLeaf;
{
	return YES; // will not be asked for documents
}

- (void)didSave;    
{
	if ([self isDeleted])
		return;
	
	SSScannedDocumentID *documentID = [self objectID];
	
	NSURL *fileReferenceURL = self.fileReferenceURL;
	if (fileReferenceURL != nil) {
		SSScannedDocumentID *oldID = [fileReferenceURLToDocumentID objectForKey:fileReferenceURL];
		if (![documentID isEqual:oldID])
			NSLog(@"on save [%lu] %@ => %@ (was %@)",
				  [fileReferenceURLToDocumentID count], fileReferenceURL, documentID, oldID);
		[fileReferenceURLToDocumentID setObject:documentID forKey:fileReferenceURL];		
	}
	[filenameToDocumentID setObject:documentID forKey:self.filename];
}

- (void)removeFromFolder;
{
	// manually propagate immediately so the dictionaries are consistent; don't wait for the end of the event
	NSLog(@"removing %@ from folder %@", self.filename, self.folder.name);
	[self.folder removeDocumentsObject:self];
	[[self managedObjectContext] deleteObject:self];
}

- (void)prepareForDeletion;
{
	NSURL *fileReferenceURL = self.fileReferenceURL;
	SSScannedDocumentID *documentID = [self objectID];

	if (fileReferenceURL && [documentID isEqual:[fileReferenceURLToDocumentID objectForKey:fileReferenceURL]]) {
		NSLog(@"removing %@ => %@", fileReferenceURL, documentID);
		[fileReferenceURLToDocumentID removeObjectForKey:fileReferenceURL];
	}
	NSString *filename = self.filename;
	if (filename &&[documentID isEqual:[filenameToDocumentID objectForKey:filename]])
		[filenameToDocumentID removeObjectForKey:filename];
}

@synthesize displayName;

- (void)setFileReferenceURL:(NSURL *)fileReferenceURL;
{
	[self willChangeValueForKey:SSTreeNodeAttributes.fileReferenceURL];
	[self setPrimitiveFileReferenceURL:fileReferenceURL];
	[self didChangeValueForKey:SSTreeNodeAttributes.fileReferenceURL];

	if (fileReferenceURL == nil)
		return;

	SSScannedDocumentID *documentID = [self objectID];
	SSScannedDocumentID *oldID = [fileReferenceURLToDocumentID objectForKey:fileReferenceURL];
	if (oldID == nil)
		NSLog(@"add [%lu] %@ => %@", [fileReferenceURLToDocumentID count], fileReferenceURL, documentID);
	else if (![oldID isEqual:documentID]) {
		NSLog(@"replace [%lu] %@ => %@ (was %@)", [fileReferenceURLToDocumentID count],fileReferenceURL, documentID, oldID);

		// e.g. moving a document from one folder to another
		[(SSScannedDocument *)[[self managedObjectContext] existingObjectWithID:oldID error:NULL] removeFromFolder];
	}
	[fileReferenceURLToDocumentID setObject:documentID forKey:fileReferenceURL];
	[filenameToDocumentID setObject:documentID forKey:self.filename];
}

- (NSNumber *)pageCount;
{
	// XXX why does this need to be a method?
	[self willAccessValueForKey:SSScannedDocumentAttributes.pageCount];
	NSNumber *pageCount = [self primitivePageCount];
	[self didAccessValueForKey:SSScannedDocumentAttributes.pageCount];
	
	return pageCount;
}

- (void)updatePageCount;
{
	PDFDocument *pdfDocument = [[PDFDocument alloc] initWithURL:self.fileReferenceURL];
	if (!pdfDocument)
		self.pageCount = nil;
	else
		[self setPageCountValue:[pdfDocument pageCount]];
	
	[pdfDocument release];
}

@end