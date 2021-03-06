// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI38_0_0EXConstantsBinding.h"
#import "ABI38_0_0EXUnversioned.h"

@interface ABI38_0_0EXConstantsBinding ()

@property (nonatomic, strong) NSString *appOwnership;
@property (nonatomic, strong) NSString *experienceId;
@property (nonatomic, strong) NSDictionary *unversionedConstants;

@property (nonatomic, weak) id<ABI38_0_0EXConstantsDeviceInstallationUUIDManager> deviceInstallationUUIDManager;

@end

@implementation ABI38_0_0EXConstantsBinding : ABI38_0_0EXConstantsService

- (instancetype)initWithExperienceId:(NSString *)experienceId andParams:(NSDictionary *)params deviceInstallationUUIDManager:(id<ABI38_0_0EXConstantsDeviceInstallationUUIDManager>)deviceInstallationUUIDManager
{
  if (self = [super init]) {
    _experienceId = experienceId;
    _unversionedConstants = params[@"constants"];
    _deviceInstallationUUIDManager = deviceInstallationUUIDManager;
    if (_unversionedConstants && _unversionedConstants[@"appOwnership"]) {
      _appOwnership = _unversionedConstants[@"appOwnership"];
    }
  }
  return self;
}

- (NSDictionary *)constants
{
  NSMutableDictionary *constants = [[super constants] mutableCopy];

  [constants setValue:[self expoClientVersion] forKey:@"expoVersion"];

  BOOL isDetached = NO;
#ifdef ABI38_0_0EX_DETACHED
  isDetached = YES;
#endif

  constants[@"isDetached"] = @(isDetached);
  
  if (_unversionedConstants) {
    [constants addEntriesFromDictionary:_unversionedConstants];
  }

  if ([constants[@"appOwnership"] isEqualToString:@"expo"]) {
    NSMutableDictionary *platform = [constants[@"platform"] mutableCopy];
    NSMutableDictionary *ios = [platform[@"ios"] mutableCopy];
    [ios setValue:[NSNull null] forKey:@"buildNumber"];
    [platform setValue:ios forKey:@"ios"];
    [constants setValue:platform forKey:@"platform"];
  }

  return constants;
}

- (NSString *)expoClientVersion
{
  NSString *expoClientVersion = _unversionedConstants[@"expoRuntimeVersion"];
  if (expoClientVersion) {
    return expoClientVersion;
  } else {
    // not correct in standalone apps
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  }
}

- (NSString *)installationId
{
  return [_deviceInstallationUUIDManager deviceInstallationUUID];
}

@end
