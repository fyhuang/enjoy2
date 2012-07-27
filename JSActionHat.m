//
//  JSActionHat.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

static BOOL active_eightway[36] = {
NO,  NO,  NO,  NO , // center
YES, NO,  NO,  NO , // N
YES, NO,  NO,  YES, // NE
NO,  NO,  NO,  YES, // E
NO,  YES, NO,  YES, // SE
NO,  YES, NO,  NO , // S
NO,  YES, YES, NO , // SW
NO,  NO,  YES, NO , // W
YES, NO,  YES, NO , // NW
};
static BOOL active_fourway[20] = {
NO,  NO,  NO,  NO , // center
YES, NO,  NO,  NO , // N
NO,  NO,  NO,  YES, // E
NO,  YES, NO,  NO , // S
NO,  NO,  YES, NO , // W
};

@implementation JSActionHat

- (id) init {
	if(self = [super init]) {
		subActions = [NSArray arrayWithObjects:
					  [[SubAction alloc] initWithIndex: 0 name: @"Up" base: self],
					  [[SubAction alloc] initWithIndex: 1 name: @"Down" base: self],
					  [[SubAction alloc] initWithIndex: 2 name: @"Left" base: self],
					  [[SubAction alloc] initWithIndex: 3 name: @"Right" base: self],
					  nil
					  ];
		[subActions retain];
		name = @"Hat switch";
	}
	return self;
}

-(id) findSubActionForValue: (IOHIDValueRef) value {
	int parsed = IOHIDValueGetIntegerValue(value);
	if(IOHIDElementGetLogicalMax(IOHIDValueGetElement(value)) == 7) {
		// 8-way
		switch(parsed) {
			case 0: return [subActions objectAtIndex: 0];
			case 4: return [subActions objectAtIndex: 1];
			case 6: return [subActions objectAtIndex: 2];
			case 2: return [subActions objectAtIndex: 3];
		}
	} else 	if(IOHIDElementGetLogicalMax(IOHIDValueGetElement(value)) == 8) {
		// 8-way
		switch(parsed) {
			case 1: return [subActions objectAtIndex: 0];
			case 5: return [subActions objectAtIndex: 1];
			case 7: return [subActions objectAtIndex: 2];
			case 3: return [subActions objectAtIndex: 3];
		}
	} else if(IOHIDElementGetLogicalMax(IOHIDValueGetElement(value)) == 3) {
			// 4-way
		switch(parsed) {
			case 0: return [subActions objectAtIndex: 0];
			case 2: return [subActions objectAtIndex: 1];
			case 3: return [subActions objectAtIndex: 2];
			case 1: return [subActions objectAtIndex: 3];
		}
	} else if(IOHIDElementGetLogicalMax(IOHIDValueGetElement(value)) == 4) {
		// 4-way
		switch(parsed) {
			case 1: return [subActions objectAtIndex: 0];
			case 3: return [subActions objectAtIndex: 1];
			case 4: return [subActions objectAtIndex: 2];
			case 2: return [subActions objectAtIndex: 3];
		}
	}
	return NULL;
}

-(void) notifyEvent: (IOHIDValueRef) value {
	int parsed = IOHIDValueGetIntegerValue(value);
	int size = IOHIDElementGetLogicalMax(IOHIDValueGetElement(value));
	if(size == 7 || size == 3) {
		parsed++;
		size++;
	}
	BOOL* activeSubactions = (size == 8) ? active_eightway : active_fourway;
	for(int i=0; i<4; i++)
		[[subActions objectAtIndex: i] setActive: activeSubactions[parsed * 4 + i]];
}

@end
