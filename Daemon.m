#import "Daemon.h"
#import "notify.h"

@interface Daemon () <NSXPCListenerDelegate, ExampleDaemonProtocol>

@property (nonatomic, strong, readwrite) NSXPCListener *listener;
@property (nonatomic, readwrite) BOOL started;

@property (nonatomic, readwrite) int count;

@end


@implementation Daemon

- (id) init
  {
    // Launch daemons must configure their listener with the machServiceName initializer
    _listener = [[NSXPCListener alloc] initWithMachServiceName:daemonLabel];
    _listener.delegate = self;

    _started = NO;

    return self;
  }


- (void) start
  {
    assert(_started == NO);

    // Begin listening for incoming XPC connections
    [_listener resume];

    _started = YES;
  }


- (void) stop
  {
    assert(_started == YES);

    // Stop listening for incoming XPC connections
    [_listener suspend];

    _started = NO;
  }


#pragma mark - ExampleDaemonProtocol

- (void) incrementCount
  {
    // Incrememnt the counter
    _count++;

    // Post a notification
    notify_post("com.example.daemonCounterDidChange");
  }


- (void) getCount:(void (^)(int))completion
  {
    // Pass our count back in the completion block
    completion(_count);
  }


#pragma mark - NSXPCListenerDelegate

- (BOOL) listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
  {
    // Sanity checks
    assert(listener == _listener);
    assert(newConnection != nil);

    // Configure the incoming connection
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ExampleDaemonProtocol)];
    newConnection.exportedObject = self;

    // New connections always start in a suspended state
    [newConnection resume];

    return YES;
  }


@end
