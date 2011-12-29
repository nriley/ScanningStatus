//
//  SSTreeController.m
//  Scanning Status
//
//  Created by Nicholas Riley on 12/27/11.
//  Copyright 2011 Nicholas Riley. All rights reserved.
//

#import "SSTreeController.h"
#import "SSWatchedFolder.h"

@implementation SSTreeController

- (BOOL)fetchWithRequest:(NSFetchRequest *)fetchRequest merge:(BOOL)merge error:(NSError **)error;
{
	// this emulates superclass behavior, but we need a request to inspect here
	if (fetchRequest == nil)
		fetchRequest = [self defaultFetchRequest];

	if ([[[fetchRequest entity] name] isEqual:[SSWatchedFolder entityName]])
		[fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:SSWatchedFolderRelationships.documents]];
	
	return [super fetchWithRequest:fetchRequest merge:merge error:error];
}

@end
