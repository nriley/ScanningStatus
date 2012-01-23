//
//  SSAppDelegate.h
//  Scanning Status
//
//  Created by Nicholas Riley on 12/3/11.
//  Copyright 2011 Nicholas Riley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "SCEvents.h"

@interface SSAppDelegate : NSObject <NSApplicationDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate, SCEventListenerProtocol> {
    IBOutlet NSWindow *window;
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSTreeController *treeController;
	IBOutlet NSDateFormatter *dateFormatter;
	
    QLPreviewPanel *previewPanel;
	NSMapTable *previewItemNodes;

	SCEvents *pathWatcher;
	NSMapTable *pathToWatchedFolder;
	
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (void)watchedFolderListChanged;

- (IBAction)togglePreviewPanel:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)reveal:(id)sender;

@end
