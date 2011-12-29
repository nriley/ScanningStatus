//
//  SSRemovalDateToColor.m
//  Scanning Status
//
//  Created by Nicholas Riley on 12/26/11.
//  Copyright 2011 Nicholas Riley. All rights reserved.
//

#import "SSFileReferenceToColor.h"


@implementation SSFileReferenceToColor

+ (Class)transformedValueClass;
{
    return [NSColor class];
}

+ (BOOL)allowsReverseTransformation;
{
    return NO;
}

- (id)transformedValue:(id)fileReferenceURL
{
	if (fileReferenceURL)
		return [NSColor blackColor];

	return [NSColor orangeColor];
}

@end
