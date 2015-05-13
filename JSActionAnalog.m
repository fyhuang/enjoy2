//
//  JSActionAnalog.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

@implementation JSActionAnalog

- (id) initWithIndex: (int)newIndex {
	if(self = [super init]) {
	subActions = [NSArray arrayWithObjects:
		[[SubAction alloc] initWithIndex: 0 name: @"Low" base: self],
		[[SubAction alloc] initWithIndex: 1 name: @"High" base: self],
        [[SubAction alloc] initWithIndex: 2 name: @"Analog" base: self],
		nil
	];
		[subActions retain];
	index = newIndex;
	name = [[NSString alloc] initWithFormat: @"Axis %d", (index+1)];
   }
	return self;
}

-(id) findSubActionForValue: (IOHIDValueRef) value {
    int raw = IOHIDValueGetIntegerValue(value);
    double parsed = [self getRealValue: raw];
    
    if ([[subActions objectAtIndex: 2] active]) {
        if (fabs(parsed) < 0.3) {
            return NULL;
        }
        
        return [subActions objectAtIndex: 2]; // TODO?
    }
    
    //Target* target = [[base->configsController currentConfig] getTargetForAction: [subActions objectAtIndex: 0]];
	
	if(parsed < -0.3) // fixed?!
		return [subActions objectAtIndex: 0];
	else if(parsed > 0.3)
		return [subActions objectAtIndex: 1];
	return NULL;
}

-(void) notifyEvent: (IOHIDValueRef) value {
    int raw = IOHIDValueGetIntegerValue(value);
    double parsed = [self getRealValue: raw];
    
    [[subActions objectAtIndex: 2] setActive: (fabs(parsed) > 0.3)];
	
	[[subActions objectAtIndex: 0] setActive: (parsed < -0.3)];
	[[subActions objectAtIndex: 1] setActive: (parsed > 0.3)];
}

-(double) getRealValue: (int)value {
	double parsed = -1.0 + 2.0 * (value - min) / (max - min);
    return parsed;
}

@synthesize min, max;


@end
