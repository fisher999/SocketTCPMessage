//
//  AppDelegate.m
//  SocketMessageServer
//
//  Created by Victor on 08.11.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import "AppDelegate.h"
#import "SMTCPServer.h"

@interface AppDelegate ()
@property (strong, nonatomic)  SMTCPServer *server;
@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    _server = [[SMTCPServer alloc] init];
    [_server bindWithIntervalFromFirstPort: (NSInteger) 2000 toEndPort: (NSInteger) 2046];
}

@end
