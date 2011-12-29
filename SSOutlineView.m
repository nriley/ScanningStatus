//
//  SSOutlineView.m
//  Scanning Status
//
//  Created by Nicholas Riley on 12/24/11.
//  Copyright 2011 Nicholas Riley. All rights reserved.
//

#import "SSOutlineView.h"
#import "SSAppDelegate.h"
#import "SSWatchedFolder.h"

@implementation SSOutlineView

- (void)reloadData;
{
	[super reloadData];
	NSUInteger row;
	for (row = 0 ; row < [self numberOfRows] ; row++) {
		NSTreeNode *item = [self itemAtRow:row];
		if (![item isLeaf] && [[[item representedObject] valueForKey:SSWatchedFolderAttributes.isExpanded] boolValue])
			[self expandItem:item];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@" "]) {
        [[NSApp delegate] togglePreviewPanel:self];
		return;
	}
	
	[super keyDown:theEvent];
}

@end
