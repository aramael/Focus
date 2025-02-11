//
//  PACFileManager.m
//  Focus
//
//  Created by Brad Jasper on 11/26/13.
//
//

#import "PACFileManager.h"

@implementation PACFileManager

- (id)initWithHosts:(NSArray *)hosts
{
    self = [super self];
    if (self) {
        self.hosts = hosts;
        self.proxy = @"localhost:8401";
    }
    return self;
}

- (NSString *)output
{
    NSMutableString *template = [NSMutableString stringWithString:@"function FindProxyForURL(url, host) {"];

    // TODO: Clean this up. This is a temporary fix for like buttons but this should be incorporated into a better exclusion list
    [template appendString:@"\n\tif (dnsDomainIs(host, 'ak.facebook.com')) { return 'DIRECT'; }"];
    [template appendString:@"\n\tif (dnsDomainIs(host, 'connect.facebook.net')) { return 'DIRECT'; }"];
    [template appendString:@"\n\tif (host == 'www.facebook.com' && url.indexOf('/plugins/like.php') != -1) { return 'DIRECT'; }"];
    [template appendString:@"\n\tif (dnsDomainIs(host, 'platform.twitter.com')) { return 'DIRECT'; }"];
    [template appendString:@"\n\tif (dnsDomainIs(host, 'assets.pinterest.com')) { return 'DIRECT'; }"];
    [template appendString:@"\n\tif (dnsDomainIs(host, 'apis.google.com')) { return 'DIRECT'; }"];

    
    for (NSString *host in self.hosts) {
        NSString *line = [NSString stringWithFormat:@"\n    if (dnsDomainIs(host,'%@')) return 'PROXY %@';", host, self.proxy];
        
        [template appendString:line];
    }
    
    [template appendString:@"\n    return 'DIRECT';\n}"];
    return (NSString *)template;
}


- (bool)writeToFile:(NSString *)filePath
{
    NSError *error;
    bool success = [[self output] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    LogMessageCompat(@"writeToFile: success=%d / error=%@", success, error);
    
    return error == nil && success;
}

@end
