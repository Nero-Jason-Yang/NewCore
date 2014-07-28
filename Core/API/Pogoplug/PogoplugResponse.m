#import "PogoplugResponse.h"

@interface PogoplugResponse_User ()
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
@interface PogoplugResponse_Device ()
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
@interface PogoplugResponse_Service ()
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
@interface PogoplugResponse_File ()
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
@interface PogoplugResponse_FileProperties ()
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
@interface PogoplugResponse_Share ()
- (id)initWithDictionary:(NSDictionary *)dictionary;
@end

@implementation PogoplugResponse
{
    NSDictionary *_dic;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _dic = dictionary;
    }
    return self;
}

- (PogoplugResponse_User *)user
{
    NSDictionary *dic = [_dic objectForKey:@"user"];
    if ([dic isKindOfClass:NSDictionary.class]) {
        PogoplugResponse_User *user = [[PogoplugResponse_User alloc] initWithDictionary:dic];
        return user;
    }
    return nil;
}

- (NSArray *)devices
{
    NSArray *arr = [_dic objectForKey:@"devices"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableArray *devices = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            if ([dic isKindOfClass:NSDictionary.class]) {
                [devices addObject:[[PogoplugResponse_Device alloc] initWithDictionary:dic]];
            }
        }
        return devices;
    }
    return nil;
}

- (NSArray *)features
{
    NSArray *arr = [_dic objectForKey:@"features"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableArray *features = [NSMutableArray array];
        for (NSString *str in arr) {
            if ([str isKindOfClass:NSString.class]) {
                [features addObject:str];
            }
        }
        return features;
    }
    return nil;
}

- (NSArray *)services
{
    NSArray *arr = [_dic objectForKey:@"services"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableArray *services = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            if ([dic isKindOfClass:NSDictionary.class]) {
                [services addObject:[[PogoplugResponse_Service alloc] initWithDictionary:dic]];
            }
        }
        return services;
    }
    return nil;
}

- (PogoplugResponse_File *)file
{
    NSDictionary *dic = [_dic objectForKey:@"file"];
    if ([dic isKindOfClass:NSDictionary.class]) {
        return [[PogoplugResponse_File alloc] initWithDictionary:dic];
    }
    return nil;
}

- (NSNumber *)offset
{
    NSString *str = [_dic objectForKey:@"offset"];
    if ([str isKindOfClass:NSString.class]) {
        return [NSNumber numberWithInteger:str.integerValue];
    }
    return nil;
}

- (NSNumber *)count
{
    NSString *str = [_dic objectForKey:@"count"];
    if ([str isKindOfClass:NSString.class]) {
        return [NSNumber numberWithInteger:str.integerValue];
    }
    return nil;
}

- (NSNumber *)totalCount
{
    NSString *str = [_dic objectForKey:@"totalcount"];
    if ([str isKindOfClass:NSString.class]) {
        return [NSNumber numberWithInteger:str.integerValue];
    }
    return nil;
}

- (NSArray *)files
{
    NSArray *arr = [_dic objectForKey:@"files"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableArray *files = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            if ([dic isKindOfClass:NSDictionary.class]) {
                [files addObject:[[PogoplugResponse_File alloc] initWithDictionary:dic]];
            }
        }
        return files;
    }
    return nil;
}

- (NSArray *)shares
{
    NSArray *arr = [_dic objectForKey:@"shares"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableArray *shares = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            if ([dic isKindOfClass:NSDictionary.class]) {
                [shares addObject:[[PogoplugResponse_Share alloc] initWithDictionary:dic]];
            }
        }
        return shares;
    }
    return nil;
}

- (NSString *)shareURL
{
    NSString *value = [_dic objectForKey:@"url"];
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    return nil;
}

@end


@implementation PogoplugResponse_User
{
    NSDictionary *_dic;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _dic = dictionary;
    }
    return self;
}

- (NSString *)userID
{
    return [_dic objectForKey:@"userid"];
}

- (NSString *)screenName
{
    return [_dic objectForKey:@"screenname"];
}

- (NSString *)email
{
    return [_dic objectForKey:@"email"];
}

- (NSArray *)emails
{
    NSArray *arr = [_dic objectForKey:@"emails"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableArray *emails = [NSMutableArray array];
        for (NSString *str in arr) {
            if ([str isKindOfClass:NSString.class]) {
                [emails addObject:str];
            }
        }
        return emails;
    }
    return nil;
}

- (NSString *)flags
{
    return [_dic objectForKey:@"flags"];
}

- (NSString *)locale
{
    return [_dic objectForKey:@"locale"];
}

- (NSDictionary *)options
{
    NSArray *arr = [_dic objectForKey:@"options"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        for (NSDictionary *dic in arr) {
            if ([dic isKindOfClass:NSDictionary.class]) {
                NSString *name = [dic objectForKey:@"name"];
                NSString *value = [dic objectForKey:@"value"];
                if ([name isKindOfClass:NSString.class] && [value isKindOfClass:NSString.class]) {
                    [options setObject:value forKey:name];
                }
            }
        }
        return options;
    }
    return nil;
}

@end

@implementation PogoplugResponse_Device
{
    NSDictionary *_dic;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _dic = dictionary;
    }
    return self;
}

- (NSString *)deviceID
{
    return [_dic objectForKey:@"deviceid"];
}

- (NSString *)name
{
    return [_dic objectForKey:@"name"];
}

- (NSString *)version
{
    return [_dic objectForKey:@"version"];
}

- (NSString *)flags
{
    return [_dic objectForKey:@"flags"];
}

- (NSString *)ownerID
{
    return [_dic objectForKey:@"ownerid"];
}

- (PogoplugResponse_User *)owner
{
    NSDictionary *dic = [_dic objectForKey:@"owner"];
    if ([dic isKindOfClass:NSDictionary.class]) {
        return [[PogoplugResponse_User alloc] initWithDictionary:dic];
    }
    return nil;
}

- (NSNumber *)provisionFlags
{
    NSString *str = [_dic objectForKey:@"provisionflags"];
    if (str) {
        return [NSNumber numberWithInteger:str.integerValue];
    }
    return nil;
}

- (NSArray *)services
{
    NSArray *arr = [_dic objectForKey:@"services"];
    if ([arr isKindOfClass:NSArray.class]) {
        NSMutableArray *services = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            if ([dic isKindOfClass:NSDictionary.class]) {
                [services addObject:[[PogoplugResponse_Service alloc] initWithDictionary:dic]];
            }
        }
    }
    return nil;
}

@end

@implementation PogoplugResponse_Service
{
    NSDictionary *_dic;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _dic = dictionary;
    }
    return self;
}

- (NSString *)deviceID
{
    return [_dic objectForKey:@"deviceid"];
}

- (NSString *)serviceID
{
    return [_dic objectForKey:@"serviceid"];
}

- (NSString *)sclass
{
    return [_dic objectForKey:@"sclass"];
}

- (NSString *)type
{
    return [_dic objectForKey:@"type"];
}

- (NSString *)name
{
    return [_dic objectForKey:@"name"];
}

- (NSString *)version
{
    return [_dic objectForKey:@"version"];
}

- (NSString *)apiurl
{
    return [_dic objectForKey:@"apiurl"];
}

- (NSNumber *)online
{
    NSString *str = [_dic objectForKey:@"online"];
    if (str) {
        return [NSNumber numberWithBool:[str isEqualToString:@"1"]];
    }
    return nil;
}

- (PogoplugResponse_Device *)device
{
    NSDictionary *dic = [_dic objectForKey:@"device"];
    if ([dic isKindOfClass:NSDictionary.class]) {
        return [[PogoplugResponse_Device alloc] initWithDictionary:dic];
    }
    return nil;
}

@end

@implementation PogoplugResponse_File
{
    NSDictionary *_dic;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _dic = dictionary;
    }
    return self;
}

- (NSString *)fileID
{
    return [_dic objectForKey:@"fileid"];
}

- (NSString *)parentID
{
    return [_dic objectForKey:@"parentid"];
}

- (NSString *)ownerID
{
    return [_dic objectForKey:@"ownerid"];
}

- (NSNumber *)type
{
    NSString *str = [_dic objectForKey:@"type"];
    if (str) {
        return [NSNumber numberWithInteger:str.integerValue];
    }
    return nil;
}

- (NSString *)name
{
    return [_dic objectForKey:@"name"];
}

- (NSString *)mimeType
{
    return [_dic objectForKey:@"mimetype"];
}

- (NSString *)mediaType
{
    return [_dic objectForKey:@"mediatype"];
}

- (NSNumber *)size
{
    NSString *str = [_dic objectForKey:@"size"];
    if (str) {
        return [NSNumber numberWithLongLong:str.longLongValue];
    }
    return nil;
}

- (NSNumber *)longitude
{
    NSString *str = [_dic objectForKey:@"longitude"];
    if (str) {
        return [NSNumber numberWithFloat:str.floatValue];
    }
    return nil;
}

- (NSNumber *)latitude
{
    NSString *str = [_dic objectForKey:@"latitude"];
    if (str) {
        return [NSNumber numberWithFloat:str.floatValue];
    }
    return nil;
}

- (NSDate *)ctime
{
    NSString *str = [_dic objectForKey:@"ctime"];
    if (str) {
        return [NSDate dateWithPogoplugTimeString:str];
    }
    return nil;
}

- (NSDate *)mtime
{
    NSString *str = [_dic objectForKey:@"mtime"];
    if (str) {
        return [NSDate dateWithPogoplugTimeString:str];
    }
    return nil;
}

- (NSDate *)origtime
{
    NSString *str = [_dic objectForKey:@"origtime"];
    if (str) {
        return [NSDate dateWithPogoplugTimeString:str];
    }
    return nil;
}

- (NSString *)thumbnail
{
    return [_dic objectForKey:@"thumbnail"];
}

- (NSString *)preview
{
    return [_dic objectForKey:@"preview"];
}

- (NSString *)stream
{
    return [_dic objectForKey:@"stream"];
}

- (NSString *)streamType
{
    return [_dic objectForKey:@"streamtype"];
}

- (PogoplugResponse_FileProperties *)properties
{
    NSDictionary *dic = [_dic objectForKey:@"properties"];
    if ([dic isKindOfClass:NSDictionary.class]) {
        return [[PogoplugResponse_FileProperties alloc] initWithDictionary:dic];
    }
    return nil;
}

@end

@implementation PogoplugResponse_FileProperties
{
    NSDictionary *_dic;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _dic = dictionary;
    }
    return self;
}

- (NSString *)origin
{
    return [_dic objectForKey:@"origin"];
}

- (NSString *)originID
{
    return [_dic objectForKey:@"originid"];
}

- (NSString *)title
{
    return [_dic objectForKey:@"title"];
}

- (NSString *)artist
{
    return [_dic objectForKey:@"artist"];
}

- (NSString *)album
{
    return [_dic objectForKey:@"album"];
}

- (NSString *)genre
{
    return [_dic objectForKey:@"genre"];
}

- (NSString *)originalTrackNumber
{
    return [_dic objectForKey:@"originalTrackNumber"];
}

- (NSString *)EXIFMake
{
    return [_dic objectForKey:@"EXIFMake"];
}

- (NSString *)EXIFModel
{
    return [_dic objectForKey:@"EXIFModel"];
}

- (NSString *)linkref
{
    return [_dic objectForKey:@"linkref"];
}

@end

@implementation PogoplugResponse_Share
{
    NSDictionary *_dic;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary);
    if (self = [super init]) {
        _dic = dictionary;
    }
    return self;
}

- (NSString *)deviceID
{
    return [_dic objectForKey:@"deviceid"];
}

- (NSString *)serviceID
{
    return [_dic objectForKey:@"serviceid"];
}

- (NSString *)fileID
{
    return [_dic objectForKey:@"fileid"];
}

- (NSString *)shareURL
{
    return [_dic objectForKey:@"url"];
}

- (NSString *)name
{
    return [_dic objectForKey:@"name"];
}

- (NSNumber *)passwordSet
{
    NSString *value = [_dic objectForKey:@"passwordset"];
    if (!value) {
        return nil;
    }
    return [NSNumber numberWithBool:([value isEqualToString:@"1"])];
}

- (NSString *)permissions
{
    return [_dic objectForKey:@"permissions"];
}

- (NSNumber *)type
{
    NSString *value = [_dic objectForKey:@"type"];
    if (!value) {
        return nil;
    }
    return [NSNumber numberWithInteger:value.integerValue];
}

- (NSNumber *)size
{
    NSString *value = [_dic objectForKey:@"size"];
    if (!value) {
        return nil;
    }
    return [NSNumber numberWithLongLong:value.longLongValue];
}

- (NSDate *)ctime
{
    NSString *str = [_dic objectForKey:@"ctime"];
    if (str) {
        return [NSDate dateWithPogoplugTimeString:str];
    }
    return nil;
}

- (NSDate *)mtime
{
    NSString *str = [_dic objectForKey:@"mtime"];
    if (str) {
        return [NSDate dateWithPogoplugTimeString:str];
    }
    return nil;
}

- (NSDate *)origTime
{
    NSString *str = [_dic objectForKey:@"origtime"];
    if (str) {
        return [NSDate dateWithPogoplugTimeString:str];
    }
    return nil;
}

- (NSString *)mimeType
{
    return [_dic objectForKey:@"mimetype"];
}

- (NSString *)thumbnail
{
    return [_dic objectForKey:@"thumbnail"];
}

- (NSString *)preview
{
    return [_dic objectForKey:@"preview"];
}

- (NSString *)stream
{
    return [_dic objectForKey:@"stream"];
}

- (NSString *)streamType
{
    return [_dic objectForKey:@"streamtype"];
}

@end
