//
//  TargetMouseBtn.h
//  Enjoy
//
//  Created by Yifeng Huang on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Target.h"

@interface TargetMouseBtn : Target {
    int which;
}

@property(readwrite) int which;

+(TargetMouseBtn*) unstringifyImpl: (NSArray*) comps;

@end
