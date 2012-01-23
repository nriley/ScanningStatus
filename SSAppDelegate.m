//
//  SSAppDelegate.m
//  Scanning Status
//
//  Created by Nicholas Riley on 12/3/11.
//  Copyright 2011 Nicholas Riley. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSWatchedFolder.h"
#import "SSWindowMover.h"
#import "SCEvent.h"

@implementation SSAppDelegate

+ (void)initialize;
{
	NSArray *initialSortDescriptors = [NSArray arrayWithObject:
									   [NSSortDescriptor sortDescriptorWithKey:SSTreeNodeAttributes.modificationDate ascending:NO selector:@selector(compare:)]];
	
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSArchiver archivedDataWithRootObject:initialSortDescriptors], @"SSOutlineSortDescriptors",
	  nil]];
}

- (NSManagedObjectModel *)managedObjectModel;
{
	if (managedObjectModel != nil)
		return managedObjectModel;
	
    return (managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain]);
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
{
	if (persistentStoreCoordinator != nil)
		return persistentStoreCoordinator;

	NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];

	applicationSupportDirectory = [applicationSupportDirectory stringByAppendingPathComponent:@"Scanning Status"];

	NSError *error;
    if (![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL])
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error])
			[NSApp presentError:error];
 
	NSURL *persistentStoreURL = [NSURL fileURLWithPath:[applicationSupportDirectory stringByAppendingPathComponent:@"status.xml"]];

	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:persistentStoreURL options:nil error:&error])
        [NSApp presentError:error];

	return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext;
{
	if (managedObjectContext != nil)
		return managedObjectContext;

	managedObjectContext = [[NSManagedObjectContext alloc] init];
	[managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:managedObjectContext];
	
	return managedObjectContext;
}

- (NSArray *)selectedURLs;
{
	return [[treeController selectedObjects] valueForKey:SSTreeNodeAttributes.fileReferenceURL];
}

- (void)watchedFolderListChanged;
{
	FSEventStreamEventId currentEventId = FSEventsGetCurrentEventId();
	
	if (pathWatcher == nil) {
		pathToWatchedFolder = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsOpaqueMemory capacity:10];
	} else {
		NSResetMapTable(pathToWatchedFolder);
		[pathWatcher release];
	}
	
	pathWatcher = [[SCEvents alloc] init];
	[pathWatcher setDelegate:self];
	[pathWatcher setNotificationLatency:1];
	[pathWatcher setResumeFromEventId:currentEventId];
	[pathWatcher setIgnoreEventsFromSubDirs:YES]; // XXX this isn't working?!

	// force fetch to complete so we get a list of directories to watch
	// (XXX can we optimize this so it is only required on startup?)
	[treeController fetchWithRequest:nil merge:NO error:NULL];
	
	NSArray *watchedFolders = [treeController content];
	NSArray *pathsToWatch = [watchedFolders valueForKey:@"path"];
	NSEnumerator *pathEnumerator = [pathsToWatch objectEnumerator];
	NSString *path;
	for (SSWatchedFolder *watchedFolder in watchedFolders) {
		path = [pathEnumerator nextObject];
		if (path == nil)
			continue;
		NSMapInsert(pathToWatchedFolder, path, watchedFolder);
	}

	[pathWatcher startWatchingPaths:[pathsToWatch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != nil"]]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;
{
	SEL action = [menuItem action];
	
	if (action == @selector(togglePreviewPanel:)) {
        if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
			[menuItem setTitle:@"Close Quick Look"];
			return YES;
		}
		[menuItem setTitle:@"Quick Look"];
		return ([outlineView numberOfSelectedRows] > 0);
	}
	
	if (action == @selector(reveal:))
		return ([outlineView numberOfSelectedRows] > 0);
	
	if (action == @selector(delete:)) {
		// note: [treeView selectedObjects] does not reset for empty selection
		if ([outlineView numberOfSelectedRows] == 0)
			return NO;

		for (SSTreeNode *selectedObject in [treeController selectedObjects])
			if ([selectedObject isDeletable])
				return YES;
			
		return NO;
	}
	
	return NO;
}

#pragma mark actions

- (void)save;
{
	NSError *error;
	if ([[self managedObjectContext] save:&error])
		return;
	
	NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
	NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
	for (NSError *detailedError in detailedErrors)
		NSLog(@"- %@", [detailedError userInfo]);
	
	[NSApp presentError:error];
}

- (void)delete:(id)sender;
{
	NSMutableArray *deletableIndexPaths = [[NSMutableArray alloc] init];
	NSMutableArray *remainingNodes = [[NSMutableArray alloc] init];
	for (NSTreeNode *selectedNode in [treeController selectedNodes]) {
		if ([[selectedNode representedObject] isDeletable])
			[deletableIndexPaths addObject:[selectedNode indexPath]];
		else
			[remainingNodes addObject:selectedNode];
	}

	NSUndoManager *undoManager = [[self managedObjectContext] undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName:@"Delete"];
	
	// removeObjectsAtArrangedObjectIndexPaths: doesn't fix up the selection correctly by itself
	[treeController removeObjectsAtArrangedObjectIndexPaths:deletableIndexPaths];
	[deletableIndexPaths release];

	[undoManager endUndoGrouping];

	[treeController setSelectionIndexPaths:[remainingNodes valueForKey:@"indexPath"]];
	[remainingNodes release];
	
}

- (IBAction)togglePreviewPanel:(id)sender;
{
	QLPreviewPanel *sharedPreviewPanel = [QLPreviewPanel sharedPreviewPanel];
    if ([QLPreviewPanel sharedPreviewPanelExists] && [sharedPreviewPanel isVisible])
        [sharedPreviewPanel orderOut:nil];
    else
        [sharedPreviewPanel makeKeyAndOrderFront:nil];
}

- (IBAction)reveal:(id)sender;
{
	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:[self selectedURLs]];
}

#pragma mark QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
	if (previewItemNodes == nil) {
		NSArray *selectedNodes = [treeController selectedNodes];
		
		NSPointerFunctionsOptions options = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsObjectPointerPersonality;
		previewItemNodes = [[NSMapTable alloc] initWithKeyOptions:options valueOptions:options capacity:[selectedNodes count]];

		for (NSTreeNode *selectedNode in selectedNodes)
			NSMapInsert(previewItemNodes, [selectedNode representedObject], selectedNode);
	}
	
    return NSCountMapTable(previewItemNodes);
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
	return [[treeController selectedObjects] objectAtIndex:index];
}

#pragma mark SCEventListenerProtocol

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event;
{
	if ([event eventFlags] & (SCEventStreamEventFlagHistoryDone | SCEventStreamEventFlagEventIdsWrapped))
		return;
	
	NSLog(@"event: %@", event);
	
	[(SSWatchedFolder *)NSMapGet(pathToWatchedFolder, [event eventPath]) updateFromDisk];
}

@end

@implementation SSAppDelegate (NSOutlineViewDataSource)

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index;
{
	if (item) // XXX allow dragging anywhere
		return NSDragOperationNone;

	return NSDragOperationLink;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index;
{
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
	NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSPasteboardURLReadingFileURLsOnlyKey];
	NSArray *urls = [pasteboard readObjectsForClasses:classes options:options];

	if ([urls count] == 0)
		return NO;

	NSManagedObjectContext *moc = [self managedObjectContext];
	NSUndoManager *undoManager = [moc undoManager];
	[undoManager beginUndoGrouping];
	[undoManager setActionName:[@"Add Folder" stringByAppendingString:[urls count] > 1 ? @"s" : @""]];
	
	for (NSURL *url in urls) {
		SSWatchedFolder *folder = [SSWatchedFolder insertInManagedObjectContext:moc];
		folder.fileReferenceURL = url;
		[self watchedFolderListChanged];
		[folder updateFromDisk];
	}
	
	[undoManager endUndoGrouping];
	
	return YES;
}

@end

@implementation SSAppDelegate (NSOutlineViewDelegate)

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;
{
	return ([[item representedObject] isKindOfClass:[SSWatchedFolder class]]);
}

- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn item:(id)item mouseLocation:(NSPoint)mouseLocation;
{
	return [[item representedObject] displayPath];
}

@end


@implementation SSAppDelegate (NSOutlineViewNotifications)

- (void)outlineViewItemDidCollapse:(NSNotification *)notification;
{
	SSWatchedFolder *collapsedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	collapsedItem.isExpanded = [NSNumber numberWithBool:NO];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification;
{
	SSWatchedFolder *expandedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	expandedItem.isExpanded = [NSNumber numberWithBool:YES];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
{
	[previewItemNodes release];
	previewItemNodes = nil;

	[previewPanel reloadData];
}

@end

@implementation SSAppDelegate (QLPreviewPanelController)

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel;
{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    previewPanel = [panel retain];
    panel.delegate = self;
    panel.dataSource = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    [previewPanel release];
    previewPanel = nil;
}

@end

@implementation SSAppDelegate (QLPreviewPanelDelegate)

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    if ([event type] == NSKeyDown) {
        [outlineView keyDown:event];
        return YES;
    }
    return NO;
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
	if (previewItemNodes == nil)
		return NSZeroRect;
	
	NSTreeNode *node = NSMapGet(previewItemNodes, item);
	if (node == nil)
		return NSZeroRect;
	
    NSInteger index = [outlineView rowForItem:node];
    if (index == NSNotFound)
        return NSZeroRect;
	
    NSRect rowRect = [outlineView rectOfRow:index];
    
    if (!NSIntersectsRect([outlineView visibleRect], rowRect))
        return NSZeroRect;
    
    rowRect = [outlineView convertRectToBase:rowRect];
    rowRect.origin = [[outlineView window] convertBaseToScreen:rowRect.origin];
    
    return rowRect;
}

// an icon, if we have one
// - (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect;

@end

@implementation SSAppDelegate (NSWindowDelegate)

- (BOOL)windowShouldClose:(id)sender;
{
	// applicationShouldTerminateAfterLastWindowClosed: misbehaves with Quick Look panel
	[NSApp terminate:sender];
	
	return NO;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window;
{
    return [[self managedObjectContext] undoManager];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)aWindow defaultFrame:(NSRect)defaultFrame;
{
    NSRect frame = [window frame];
    NSScrollView *scrollView = [outlineView enclosingScrollView];
    float displayedHeight = [[scrollView contentView] bounds].size.height;
    float heightChange = [[scrollView documentView] bounds].size.height - displayedHeight;
    float heightExcess;
	
    if (heightChange >= 0 && heightChange <= 1) {
        // either the window is already optimal size, or it's too big
        float rowHeight = [outlineView rowHeight] + [outlineView intercellSpacing].height;
        heightChange = (rowHeight * [outlineView numberOfRows]) - displayedHeight;
    }
	
    frame.size.height += heightChange;
	
    if ( (heightExcess = [window minSize].height - frame.size.height) > 1 ||
		(heightExcess = [window maxSize].height - frame.size.height) < 1) {
        heightChange += heightExcess;
        frame.size.height += heightExcess;
    }
	
    frame.origin.y -= heightChange;
	
    return frame;
}

@end

@implementation SSAppDelegate (NSApplicationDelegate)

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{	
	[dateFormatter setDoesRelativeDateFormatting:YES];
	
	[outlineView registerForDraggedTypes:[NSArray arrayWithObjects:
										  // XXX internal type for reordering
										  NSURLPboardType,			// single url from pasteboard
										  NSFilenamesPboardType,	// from Safari or Finder
										  NSFilesPromisePboardType,	// from Safari or Finder (multiple URLs)
										  nil]];

	[self watchedFolderListChanged];
	
	[[SSWindowMover alloc] initWithBundleIdentifier:@"jp.co.pfu.ScanSnap.ScanToFolder" otherWindow:window];
	// [[SSWindowMover alloc] initWithBundleIdentifier:@"com.apple.Preview" otherWindow:window];
	
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
	[self save];
}

@end

@implementation SSAppDelegate (NSManagedObjectContextNotifications)

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification;
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(save) withObject:NULL afterDelay:0.2];
}

@end