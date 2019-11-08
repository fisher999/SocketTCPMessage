//
//  SocketServer.h
//  SocketMessageClient
//
//  Created by Victor on 26.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTCPSocketStreams.h"

@interface SMTCPServer: NSObject

@property (strong, nonatomic) NSMutableArray<SMTCPSocketStreams *> *socketStreams;

- (bool)bindWithPort: (NSInteger) port;
- (bool)bindWithIntervalFromFirstPort: (NSInteger) firstPort toEndPort: (NSInteger) endPort;
- (void)listen;
- (void)close;

@end
