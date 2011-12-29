#import "_SSTreeNode.h"

#import <Quartz/Quartz.h>

@interface SSTreeNode : _SSTreeNode <QLPreviewItem> {}

- (NSString *)path;
- (NSString *)displayPath;

- (BOOL)isDeletable;
- (BOOL)updateBookmark;

// implement in subclasses
- (BOOL)isLeaf;
- (NSString *)displayName;
- (NSNumber *)pageCount;

@end
