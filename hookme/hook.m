//
//  hookme.m
//  hookme
//
//  Created by BlueCocoa on 2017/8/11.
//  Copyright (c) 2017 BlueCocoa. All rights reserved.
//

#import "BigBang.h"

static void __attribute__((constructor)) entry() {
    [BigBang hookClass:@"ProtectedClass"];
}
