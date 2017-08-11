//
//  ViewController.m
//  ochookme
//
//  Created by BlueCocoa on 2017/8/11.
//  Copyright © 2017年 BlueCocoa. All rights reserved.
//

#import "ViewController.h"
#import <dlfcn.h>
#import <stdarg.h>
#import <objc/runtime.h>
#import <setjmp.h>

static jmp_buf protectionJMP;

@interface ProtectedClass : NSObject

// 一些需要保护的方法
- (void)someImportantMethod:(id)arg;

// 取一个有迷惑性的方法名
- (void)aConfusionMethodName:(id)arg, ...;

@end

@implementation ProtectedClass

// 一些需要保护的方法
- (void)someImportantMethod:(id)arg {
    // whatever
}

// 取一个有迷惑性的方法名
- (void)aConfusionMethodName:(id)arg, ... {
    // 在正式开始前做别的 (有意义/无意义均可)
    va_list arg_ptr;
    int j = 0;
    va_start(arg_ptr, arg);
    j = va_arg(arg_ptr, int);
    va_end(arg_ptr);
    if (j != 1) {
        NSLog(@"Error: forwarded message!");
        
        // 使用longjmp, 这样没有call stack保留
        // 保护这个迷惑性函数
        longjmp(protectionJMP, 1);
    } else {
        NSLog(@"So far so good.");
    }
}

@end

static void inline protection() {
    // 这里的 Selector 字符串如何保护不是重点, 但是也有很多方法
    IMP target = method_getImplementation(class_getInstanceMethod([ProtectedClass class], NSSelectorFromString(@"aConfusionMethodName:")));
    
    // 增加一个 int 类型的参数作为标记
    typedef void(*targetMethodImplmentation)(id, SEL, id, /* magic */ int);
    id obj = [[ProtectedClass alloc] init];
    ((targetMethodImplmentation)target)(obj, NSSelectorFromString(@"aConfusionMethodName:"), nil, 1);
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[ProtectedClass alloc] init] someImportantMethod:[NSDate date]];
    
    // 使用 NSTimer 或者直接 addRunLoop 持续检测
    [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        protection();
    }];
    
    // 在其他地方偶尔写上一句也可以 (inline)
    protection();
}

@end
