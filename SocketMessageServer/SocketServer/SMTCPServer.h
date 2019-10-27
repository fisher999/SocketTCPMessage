//
//  SocketServer.h
//  SocketMessageClient
//
//  Created by Victor on 26.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMTCPServer;

@interface SMTCPServer: NSThread

- (void)bindWithPort: (NSInteger) port;
- (void)listen;
- (void)sendMessage: (NSString *) message;
- (void)close;

@end
