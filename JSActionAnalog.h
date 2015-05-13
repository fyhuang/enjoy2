//
//  JSActionAnalog.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class JSAction;

@interface JSActionAnalog : JSAction {
	double offset, min, max;
}

@property(readwrite) double offset;
@property(readwrite) double min;
@property(readwrite) double max;

- (id) initWithIndex: (int)newIndex;
-(double) getRealValue: (int) value;

@end
