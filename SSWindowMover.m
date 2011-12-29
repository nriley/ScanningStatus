//
//  SSWindowMover.m
//  Scanning Status
//
//  Created by Nicholas Riley on 12/28/11.
//  Copyright 2011 Nicholas Riley. All rights reserved.
//

#import "SSWindowMover.h"

@interface SSWindowMover ()

- (void)setApplication:(NSRunningApplication *)application;
- (void)focusedWindowChanged:(AXUIElementRef)window;
- (void)resizeFocusedWindow;

@end

@implementation SSWindowMover

- (id)initWithBundleIdentifier:(NSString *)bundleIdentifier otherWindow:(NSWindow *)window;
{
	if ( (self = [super init]) != nil) {
	
		if (!AXAPIEnabled())
			return nil;
		
		applicationBundleIdentifier = [bundleIdentifier retain];
		otherWindow = [window retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResizeOrMove:) name:NSWindowDidResizeNotification object:window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResizeOrMove:) name:NSWindowDidMoveNotification object:window];

		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidLaunchApplication:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
		
		NSArray *applications = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
		if ([applications count] > 0)
			[self setApplication:[applications objectAtIndex:0]];
	}
	
	return self;
}

- (void)dealloc;
{
	[applicationBundleIdentifier release];
	[otherWindow release];
	
	[self setApplication:NULL];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark accessibility utilities

// from UIElementUtilities

+ (NSString *)descriptionOfUIElement:(AXUIElementRef)element;
{
    NSString *description = NULL;
	
	NSString *role;
	if (AXUIElementCopyAttributeValue(element, kAXRoleAttribute, (CFTypeRef *)&role) != kAXErrorSuccess)
		return nil;
	
	NSString *title = nil;
	AXUIElementCopyAttributeValue(element, kAXTitleAttribute, (CFTypeRef *)&title);
	
	if (title != nil) {
		description = [NSString stringWithFormat:@"<%@: '%@'>", role, title];
		[title release];
	} else
		description = [NSString stringWithFormat:@"<%@>", role];
	
	[role release];
    
    return description;
}

+ (id)valueOfAttribute:(const void *)attribute ofUIElement:(AXUIElementRef)element;
{
    id result = nil;
	AXError err = AXUIElementCopyAttributeValue(element, (CFStringRef)attribute, (CFTypeRef *)&result);
	
    if (err == kAXErrorSuccess)
		[result autorelease];
	else
		NSLog(@"Can't copy attribute %@ of %@ (%d)", attribute, [self descriptionOfUIElement:element], err);
	
    return result;
}

+ (NSRect)flippedScreenBounds:(NSRect)bounds;
{
    float screenHeight = NSMaxY([[[NSScreen screens] objectAtIndex:0] frame]);
    bounds.origin.y = screenHeight - NSMaxY(bounds);
    return bounds;
}

+ (NSRect)frameOfUIElement:(AXUIElementRef)element;
{
    id elementPosition = [self valueOfAttribute:NSAccessibilityPositionAttribute ofUIElement:element];
    id elementSize = [self valueOfAttribute:NSAccessibilitySizeAttribute ofUIElement:element];
    if (elementPosition == nil || elementSize == nil)
		return NSZeroRect;
	
	NSRect topLeftWindowRect;
	AXValueGetValue((AXValueRef)elementPosition, kAXValueCGPointType, &topLeftWindowRect.origin);
	AXValueGetValue((AXValueRef)elementSize, kAXValueCGSizeType, &topLeftWindowRect.size);
	
	return [self flippedScreenBounds:topLeftWindowRect];
}

static void SSFocusedWindowChanged(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *self) {
    [(id)self focusedWindowChanged: element];
}

- (void)setApplication:(NSRunningApplication *)application;
{
	if (focusedWindow != NULL)
		CFRelease(focusedWindow);
	
	if (observer != NULL) {
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
		CFRelease(observer);
	}
		
	if (applicationElement != NULL)
		CFRelease(applicationElement);
	
	if (!application)
		return;
	
	pid_t pid = application.processIdentifier;
	
	applicationElement = AXUIElementCreateApplication(pid);
	
    AXError err = AXObserverCreate(pid, SSFocusedWindowChanged, &observer);
	if (err != kAXErrorSuccess) {
		NSLog(@"Couldn't create observer for pid %d (%d)", pid, err);
		return;
	}
    CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer),kCFRunLoopDefaultMode);

    err = AXObserverAddNotification(observer, applicationElement, kAXFocusedWindowChangedNotification, self);
	if (err != kAXErrorSuccess)
		NSLog(@"Couldn't add focused window changed notification for pid %d (%d)", pid, err);
	
	NSLog(@"application: %@", application);
	
	[self focusedWindowChanged:(AXUIElementRef)[SSWindowMover valueOfAttribute:kAXFocusedWindowAttribute ofUIElement:applicationElement]];
}

- (void)workspaceDidLaunchApplication:(NSNotification *)notification;
{
	NSRunningApplication *application = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
	
	if (![application.bundleIdentifier isEqualToString:applicationBundleIdentifier])
		return;
	
	[self setApplication:application];
}

- (void)focusedWindowChanged:(AXUIElementRef)window;
{
	if (window == NULL)
		return;
	
	NSNumber *isModal = [SSWindowMover valueOfAttribute:kAXModalAttribute ofUIElement:window];
	if (isModal == nil || [isModal boolValue]) {
		NSLog(@"window is modal, skipping: %@", [SSWindowMover descriptionOfUIElement: window]);
		return;
	}
		
	if (focusedWindow != NULL)
		CFRelease(focusedWindow);
	
	NSLog(@"window: %@", [SSWindowMover descriptionOfUIElement: window]);
	focusedWindow = CFRetain(window);
	
	[self resizeFocusedWindow];
}

- (void)resizeFocusedWindow;
{
	if (focusedWindow == nil)
		return;
	
	NSRect focusedFrame = [SSWindowMover frameOfUIElement:focusedWindow];
	if (NSEqualRects(focusedFrame, NSZeroRect))
		return;

	NSScreen *screen = [otherWindow screen];
	NSRect screenFrame = [screen frame];
	if (!NSContainsRect(screenFrame, focusedFrame))
		return; // XXX zoom later?
	
	NSRect otherFrame = [otherWindow frame];
	NSRect newFrame = [screen visibleFrame];

	newFrame.origin.x = NSMaxX(otherFrame) + 10;
	newFrame.size.width -= NSMaxX(otherFrame) + 10;
	newFrame = [SSWindowMover flippedScreenBounds: newFrame];
	
	AXValueRef position = AXValueCreate(kAXValueCGPointType, &newFrame.origin);
	AXValueRef size = AXValueCreate(kAXValueCGSizeType, &newFrame.size);
	AXUIElementSetAttributeValue(focusedWindow, (CFStringRef)NSAccessibilitySizeAttribute, size);
	AXUIElementSetAttributeValue(focusedWindow, (CFStringRef)NSAccessibilityPositionAttribute, position);
	// in case the size gets adjusted when the window is moved
	AXUIElementSetAttributeValue(focusedWindow, (CFStringRef)NSAccessibilitySizeAttribute, size);
	if (position)
		CFRelease(position);
	if (size)
		CFRelease(size);
}

- (void)windowDidResizeOrMove:(NSNotification *)notification;
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(resizeFocusedWindow) withObject:NULL afterDelay:0.2];
}
			 
@end