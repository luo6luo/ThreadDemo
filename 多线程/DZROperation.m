//
//  DZROperation.m
//  多线程
//
//  Created by dundun on 2018/5/22.
//  Copyright © 2018年 顿顿. All rights reserved.
//

#import "DZROperation.h"

@implementation DZROperation

- (void)main
{
    for (int i = 0; i < 3; i++) {
        NSLog(@"DZROperation --> %i, %@",i, [NSThread currentThread]);
    }
}

@end
