//
//  TargetMouseScroll.h
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TargetMouseScroll : Target {
    int howMuch;
}

@property(readwrite) int howMuch;

+(TargetMouseScroll*) unstringifyImpl: (NSArray*) comps;

@end
