//
//  SocketServer.h
//  SocketMessageClient
//
//  Created by Victor on 26.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMTCPServer;

@protocol SMTCPServerDelegate
- (void)SMTCPServer:(SMTCPServer *) server didSendMessage: (NSString *) message;
@end

@interface SMTCPServer: NSThread

@property (weak, nonatomic) id<SMTCPServerDelegate> delegate;

- (void)bindWithPort: (NSInteger) port;
- (void)listen;
- (void)sendMessage: (NSString *) message;
- (void)close;

@end
