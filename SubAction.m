//
//  SubAction.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

@implementation SubAction

@synthesize base, name, index, active;

-(id) initWithIndex:(int)newIndex name: (NSString*)newName base: (JSAction*)newBase {
	if(self = [super init]) {
		[self setName: newName];
		[self setBase: newBase];
		[self setIndex: newIndex];
	}
	return self;
}

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"%@~%d", [base stringify], index];
}

@end
