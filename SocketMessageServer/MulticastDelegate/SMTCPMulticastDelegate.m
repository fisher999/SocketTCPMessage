//
//  SMTCPMulticastDelegate.m
//  SocketMessageServer
//
//  Created by Victor on 27.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTCPMulticastDelegate.h"

@implementation SMTCPMulticastDelegate {
    NSMutableArray* _delegates;
}

- (id)init
{
    if (self = [super init])
    {
        _delegates = [NSMutableArray array];
    }
    return self;
}

- (void)addDelegate:(id)delegate
{
    [_delegates addObject:delegate];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    for(id delegate in _delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        for(id delegate in _delegates) {
            if ([delegate respondsToSelector:aSelector]) {
                return [delegate methodSignatureForSelector:aSelector];
            }
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for(id delegate in _delegates) {
        if ([delegate respondsToSelector:[anInvocation selector]]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

@end
