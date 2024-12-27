//
//  ISError.h
//  IronSource
//
//  Created by Roni Parshani on 1/5/15.
//  Copyright (c) 2015 IronSource. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kSSErrorsOnlyCharacterNumbers =
    @"- should contain only english characters and numbers";
static NSString *const kSSErrorsLength5to10 = @"- length should be between 5-10 characters";
static NSString *const kSSErrorsAppKey = @"appKey";
static NSString *const kSSErrorsUserId = @"UserId";
static NSString *const kSSErrorsForSS = @"for IronSource";

static NSString *const kEmptyString = @"";

typedef NS_ENUM(NSUInteger, ISErrorCode) {

  ERROR_CODE_DECRYPT_FAILED = 1,
  ERROR_CODE_NO_ADAPTIVE_SUPPORTIVE_NETWORKS = 2,

  ERROR_CODE_NO_CONFIGURATION_AVAILABLE = 501,
  ERROR_CODE_USING_CACHED_CONFIGURATION = 502,
  ERROR_CODE_KEY_NOT_SET = 505,
  ERROR_CODE_INVALID_KEY_VALUE = 506,
  ERROR_CODE_INIT_FAILED = 508,
  ERROR_CODE_NO_ADS_TO_SHOW = 509,
  ERROR_CODE_GENERIC = 510,
  ERROR_CODE_NO_ADS_TO_RELOAD = 519,
  ERROR_NO_INTERNET_CONNECTION = 520,
  ERROR_MULTIPLE_IRONSOURCE_APP_KEY = 522,
  ERROR_PLACEMENT_CAPPED = 524,
  ERROR_AD_FORMAT_CAPPED = 525,
  ERROR_REACHED_CAP_LIMIT_PER_SESSION = 526,
  ERROR_UNKNOWN_INSTANCE_ID = 527,
  ERROR_SEND_EVENTS_FAILURE = 528,
  ERROR_PULL_LOCAL_FAILURE_FAILURE = 529,
  ERROR_AD_UNIT_CAPPED = 530,

  ERROR_BN_LOAD_AFTER_INIT_FAILED = 600,
  ERROR_BN_LOAD_AFTER_LONG_INITIATION = 601,
  ERROR_BN_INIT_FAILED_AFTER_LOAD = 602,
  ERROR_BN_LOAD_PLACEMENT_CAPPED = 604,
  ERROR_BN_LOAD_EXCEPTION = 605,
  ERROR_BN_LOAD_NO_FILL = 606,
  ERROR_BN_INSTANCE_INIT_TIMEOUT = 607,
  ERROR_BN_INSTANCE_LOAD_TIMEOUT = 608,
  ERROR_BN_INSTANCE_RELOAD_TIMEOUT = 609,
  ERROR_BN_INSTANCE_LOAD_EMPTY_BANNER = 610,
  ERROR_BN_INSTANCE_LOAD_EMPTY_ADAPTER = 611,
  ERROR_BN_INSTANCE_INIT_EXCEPTION = 612,
  ERROR_BN_RELOAD_SKIP_INVISIBLE = 613,
  ERROR_BN_RELOAD_SKIP_BACKGROUND = 614,
  ERROR_BN_LOAD_NO_CONFIG = 615,
  ERROR_BN_UNSUPPORTED_SIZE = 616,
  ERROR_DO_BN_INSTANCE_LOAD_EMPTY_SERVER_DATA = 618,
  ERROR_DO_BN_LOAD_ALREADY_IN_PROGRESS = 619,
  ERROR_DO_BN_LOAD_BEFORE_INIT_SUCCESS = 620,
  ERROR_DO_BN_INSTANCE_LOAD_AUCTION_FAILED = 621,
  ERROR_CODE_NO_AD_UNIT_SPECIFIED = 624,
  ERROR_CODE_LOAD_BEFORE_INIT_SUCCESS_CALLBACK = 625,
  ERROR_CODE_INVALID_AD_UNIT_ID = 626,
  ERROR_IS_LOAD_FAILED_ALREADY_CALLED = 627,
  ERROR_CODE_SHOW_BEFORE_LOAD_SUCCESS_CALLBACK = 628,
  ERROR_CODE_LOAD_WHILE_SHOW = 629,
  ERROR_CODE_SHOW_WHILE_SHOW = 630,
  ERROR_CODE_SHOW_CONTROLLER_NIL = 631,
  ERROR_CODE_SHOW_VIEW_CONTROLLER_NIL = 632,

  ERROR_NT_LOAD_AFTER_INIT_FAILED = 700,
  ERROR_NT_LOAD_AFTER_LONG_INITIATION = 701,
  ERROR_NT_INIT_FAILED_AFTER_LOAD = 702,
  ERROR_NT_LOAD_WHILE_LONG_INITIATION = 703,
  ERROR_NT_LOAD_PLACEMENT_CAPPED = 704,
  ERROR_NT_LOAD_EXCEPTION = 705,
  ERROR_NT_LOAD_NO_FILL = 706,
  ERROR_NT_INSTANCE_INIT_TIMEOUT = 707,
  ERROR_NT_INSTANCE_LOAD_TIMEOUT = 708,
  ERROR_NT_INSTANCE_LOAD_EMPTY_ADAPTER = 711,
  ERROR_NT_INSTANCE_INIT_EXCEPTION = 712,
  ERROR_NT_LOAD_NO_CONFIG = 715,
  ERROR_NT_INSTANCE_LOAD_EMPTY_SERVER_DATA = 718,
  ERROR_NT_NETWORK_ADAPTER_IS_NULL = 719,
  ERROR_NT_NETWORK_NATIVE_AD_PARAMS_NIL = 720,
  ERROR_NT_NETWORK_NATIVE_AD_LOAD_FAILED = 721,

  AUCTION_ERROR_REQUEST = 1000,
  AUCTION_ERROR_RESPONSE_CODE_NOT_VALID = 1001,
  AUCTION_ERROR_PARSE = 1002,
  AUCTION_ERROR_DECRYPTION = 1003,
  AUCTION_ERROR_EMPTY_WATERFALL = 1004,
  AUCTION_ERROR_NO_CANDIDATES = 1005,
  AUCTION_ERROR_CONNECTION_TIMED_OUT = 1006,
  AUCTION_ERROR_REQUEST_MISSING_PARAMS = 1007,
  AUCTION_ERROR_DECOMPRESSION = 1008,

  NOTIFICATIONS_ERROR_LOADED_NOT_FOUND = 1010,
  NOTIFICATIONS_ERROR_SHOWING_NOT_FOUND = 1011,

  ERROR_SESSION_KEY_ENCRYPTION_FAILURE = 1015,

  ERROR_NT_EMPTY_DEFAULT_PLACEMENT = 1018,
  ERROR_IS_EMPTY_DEFAULT_PLACEMENT = 1020,
  ERROR_RV_EMPTY_DEFAULT_PLACEMENT = 1021,
  ERROR_RV_SHOW_CALLED_DURING_SHOW = 1022,
  ERROR_RV_SHOW_CALLED_WRONG_STATE = 1023,
  ERROR_RV_LOAD_FAILED_NO_CANDIDATES = 1024,
  ERROR_LOAD_FAILED_TIMEOUT = 1025,
  ERROR_RV_LOAD_DURING_LOAD = 1026,
  ERROR_RV_LOAD_DURING_SHOW = 1027,
  ERROR_RV_LOAD_SUCCESS_UNEXPECTED = 1028,
  ERROR_RV_LOAD_SUCCESS_WRONG_AUCTION_ID = 1029,
  ERROR_RV_LOAD_FAIL_UNEXPECTED = 1030,
  ERROR_RV_LOAD_FAIL_WRONG_AUCTION_ID = 1031,
  ERROR_RV_INIT_FAILED_TIMEOUT = 1032,
  ERROR_RV_LOAD_FAIL_DUE_TO_INIT = 1033,
  ERROR_RV_LOAD_UNEXPECTED_CALLBACK = 1034,
  ERROR_IS_LOAD_FAILED_NO_CANDIDATES = 1035,
  ERROR_IS_SHOW_CALLED_DURING_SHOW = 1036,
  ERROR_IS_LOAD_DURING_SHOW = 1037,
  ERROR_RV_SHOW_EXCEPTION = 1038,
  ERROR_IS_SHOW_EXCEPTION = 1039,
  ERROR_RV_INSTANCE_INIT_EXCEPTION = 1040,
  ERROR_IS_INSTANCE_INIT_EXCEPTION = 1041,
  ERROR_BN_LOAD_FAILED_NO_CANDIDATES = 1044,
  ERROR_NT_LOAD_FAILED_NO_CANDIDATES = 1045,

  ERROR_DO_IS_LOAD_ALREADY_IN_PROGRESS = 1050,
  ERROR_DO_IS_CALL_LOAD_BEFORE_SHOW = 1051,
  ERROR_DO_IS_LOAD_TIMED_OUT = 1052,
  ERROR_DO_RV_LOAD_ALREADY_IN_PROGRESS = 1053,
  ERROR_DO_RV_SHOW_CALLED_BEFORE_LOAD = 1054,
  ERROR_DO_RV_LOAD_TIMED_OUT = 1055,
  ERROR_DO_RV_LOAD_DURING_SHOW = 1056,
  ERROR_RV_EXPIRED_ADS = 1057,
  ERROR_DO_BN_LOAD_MISSING_VIEW_CONTROLLER = 1060,
  ERROR_RV_LOAD_AFTER_LONG_INITIATION = 1061,
  ERROR_DO_RV_INSTANCE_LOAD_EMPTY_SERVER_DATA = 1062,
  ERROR_CODE_MISSING_CONFIGURATION = 1063,
  ERROR_DO_IS_SHOW_DURING_SHOW = 1064,
  ERROR_DO_IS_SHOW_DURING_LOAD = 1065,
  ERROR_DO_IS_SHOW_NO_AVAILABLE_ADS = 1066,
  ERROR_DO_RV_SHOW_DURING_SHOW = 1067,
  ERROR_DO_RV_SHOW_DURING_LOAD = 1068,
  ERROR_DO_RV_SHOW_NO_AVAILABLE_ADS = 1069,
  ERROR_DO_RV_INSTANCE_LOAD_AUCTION_FAILED = 1070,
  ERROR_RV_LOAD_AFTER_INIT_FAILED = 1072,

  ERROR_RV_LOAD_NO_FILL = 1058,
  ERROR_IS_LOAD_NO_FILL = 1158,

  ERROR_IS_LOAD_AFTER_INIT_FAILED = 1160,
  ERROR_IS_LOAD_AFTER_LONG_INITIATION = 1161,
  ERROR_DO_IS_INSTANCE_LOAD_EMPTY_SERVER_DATA = 1162,
  ERROR_DO_IS_INSTANCE_LOAD_EMPTY_ADAPTER = 1163,
  ERROR_DO_IS_INSTANCE_LOAD_AUCTION_FAILED = 1164,

  ERROR_CONSENT_VIEW_TYPE_NOT_FOUND = 1601,
  ERROR_CONSENT_VIEW_DICTIONARY_NOT_FOUND = 1602,
  ERROR_CONSENT_VIEW_URL_NOT_FOUND = 1603,
  ERROR_CONSENT_VIEW_NOT_LOADED = 1604,
  ERROR_CONSENT_VIEW_LOAD_FAILED = 1605,
  ERROR_CONSENT_VIEW_SHOW_DURING_SHOW = 1606,
  ERROR_CONSENT_VIEW_CANNOT_BE_OPENED = 1607,
  ERROR_CONSENT_VIEW_LOAD_DURING_LOAD = 1608,

  // TestSuite error codes
  ERROR_CODE_TEST_SUITE_SDK_NOT_INITIALIZED = 1721,
  ERROR_CODE_TEST_SUITE_DISABLED = 1722,
  ERROR_CODE_TEST_SUITE_EXCEPTION_ON_LAUNCH = 1723,
  ERROR_CODE_TEST_SUITE_WEB_CONTROLLER_NOT_LOADED = 1724,
  ERROR_CODE_TEST_SUITE_NO_NETWORK_CONNECTIVITY = 1725,

  // Smash TS error codes
  ERROR_CODE_BIDDING_DATA_EXCEPTION = 5001,
  ERROR_CODE_IS_READY_EXCEPTION = 5002,
  ERROR_CODE_LOAD_IN_PROGRESS_EXCEPTION = 5003,
  ERROR_CODE_SHOW_IN_PROGRESS_EXCEPTION = 5004,
  ERROR_CODE_LOAD_EXCEPTION = 5005,
  ERROR_CODE_SHOW_FAILED_EXCEPTION = 5006,
  ERROR_CODE_INIT_SUCCESS_EXCEPTION = 5007,
  ERROR_CODE_INIT_FAILED_EXCEPTION = 5008,
  ERROR_CODE_AD_CLOSE_EXCEPTION = 5008,
  ERROR_CODE_DESTROY_EXCEPTION = 5009,
  ERROR_CODE_INTERNAL_EXCEPTION = 5010,
  ERROR_CODE_SMASH_IS_NIL = 5012,
  ERROR_CODE_SMASH_INSTANCE_NAME_IS_NIL = 5013,

  // Init error codes
  ERROR_OLD_INIT_API_APP_KEY_NOT_VALID = 2010,
  ERROR_NEW_INIT_API_ALREADY_CALLED = 2020,
  ERROR_OLD_API_INIT_IN_PROGRESS = 2030,
  ERROR_INIT_ALREADY_FINISHED = 2040,
  ERROR_LEGACY_INIT_FAILED = 2060,
  ERROR_INIT_HTTP_REQUEST_FAILED = 2070,
  ERROR_INIT_INVALID_RESPONSE = 2080,
  ERROR_INIT_DECRYPT_FAILED = 2090,
  ERROR_INIT_NO_RESPONSE_KEY = 2100,
  ERROR_OLD_INIT_API_MULTIPLE_CALLS = 2110,
  ERROR_INIT_DECOMPRESS_FAILED = 2120,

  // Capping service error codes
  ERROR_CAPPING_VALIDATION_FAILED = 3000,
  ERROR_DELIVERY_CAPPING_VALIDATION_FAILED = 3001,
  ERROR_CAPPING_ENABLED_FALSE = 3002,
  ERROR_CAPPING_CONFIG_ADDITION_FAILED = 3003,

  // Reward
  ERROR_REWARD_VALIDATION_FAILED = 3004
};

@interface ISError : NSError

@property(strong) NSString *prefix;
@property(strong) NSString *suffix;

+ (NSError *)createError:(ISErrorCode)errorCode;
+ (NSError *)createError:(ISErrorCode)errorCode withParams:(NSArray *)params;
+ (NSError *)createError:(ISErrorCode)errorCode withMessage:(NSString *)message;
+ (NSError *)createErrorWithDomain:(NSString *)domain
                              code:(ISErrorCode)code
                           message:(NSString *)message;
+ (NSError *)appendError:(NSError *)error withPrefix:(NSString *)prefix;
+ (NSError *)appendError:(NSError *)error withSuffix:(NSString *)suffix;
+ (ISErrorCode)getCode:(ISErrorCode)errorCode;

@end