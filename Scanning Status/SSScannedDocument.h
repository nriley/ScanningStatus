#import "_SSScannedDocument.h"

@interface SSScannedDocument : _SSScannedDocument {}

+ (SSScannedDocument *)scannedDocumentWithFileReferenceURL:(NSURL *)fileReferenceURL inManagedObjectContext:(NSManagedObjectContext *)moc;
+ (SSScannedDocument *)scannedDocumentWithFilename:(NSString *)filename inManagedObjectContext:(NSManagedObjectContext *)moc;

- (void)updatePageCount;

- (void)removeFromFolder;

@end
