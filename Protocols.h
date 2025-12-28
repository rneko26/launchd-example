static NSString *daemonLabel = @"com.example.daemon";

@protocol ExampleDaemonProtocol

- (void) incrementCount;

- (void) getCount:(void(^)(int count))completion;

@end