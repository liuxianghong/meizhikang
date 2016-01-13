//
//  BaseHTTPRequestOperationManager.h
//  DoctorFei_iOS
//
//  Created by GuJunjia on 14/11/30.
//
//

//#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"

@interface BaseHTTPRequestOperationManager : AFHTTPSessionManager
+ (BaseHTTPRequestOperationManager *)sharedManager;
- (void)defaultHTTPWithMethod:(NSString *)method WithParameters:(id)parameters  post:(BOOL)bo success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)filePostWithUrl:(NSString *)urlString WithParameters:(NSData *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)getWithUrl:(NSString *)urlString WithParameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
