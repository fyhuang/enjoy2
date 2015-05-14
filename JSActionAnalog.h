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
	double min, max;
    
    double discreteThreshold;
    double analogThreshold;
}

@property(readwrite) double min;
@property(readwrite) double max;
@property(readwrite) double discreteThreshold;
@property(readwrite) double analogThreshold;

- (id) initWithIndex: (int)newIndex;
-(double) getRealValue: (int) value;

@end
