//
//  main.m
//  SocketMessageServer
//
//  Created by Victor on 26.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SMTCPServer.h"
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        [application setDelegate:[[AppDelegate alloc] init] ];
        [application run];
    }
    return 0;
}
