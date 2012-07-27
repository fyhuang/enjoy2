//
//  TargetMouseBtn.h
//  Enjoy
//
//  Created by Yifeng Huang on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Target.h"

@interface TargetMouseBtn : Target {
    CGMouseButton which;
}

@property(readwrite) CGMouseButton which;

+(TargetMouseBtn*) unstringifyImpl: (NSArray*) comps;

@end
