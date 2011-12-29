//
//  SSWindowMover.h
//  Scanning Status
//
//  Created by Nicholas Riley on 12/28/11.
//  Copyright 2011 Nicholas Riley. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SSWindowMover : NSObject {
	NSString *applicationBundleIdentifier;
	NSWindow *otherWindow;

	AXUIElementRef applicationElement;
	AXObserverRef observer;
	AXUIElementRef focusedWindow;
}

- (id)initWithBundleIdentifier:(NSString *)bundleIdentifier otherWindow:(NSWindow *)window;

@end
