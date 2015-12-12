//
//  NetWorkingContents.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/12.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "NetWorkingContents.h"

@implementation NetWorkingContents
+(NSString *)getReturnDescription:(NSInteger)code{
    NSDictionary *dic = @{
                          @"200" : @"正常",
                          @"100" : @"token过期或错误",
                          @"101" : @"业务暂停",
                          @"102" : @"帐号错误，注册请求即用户已经注册，登录请求即该用户未注册",
                          @"103" : @"密码错误",
                          @"104" : @"昵称非法",
                          @"105" : @"参数错误，例如本地服务系统传来的组id错误等。",
                          @"110" : @"短信发送失败",
                          @"120" : @"邀请消息暂时不能接收",
                          @"130" : @"验证码错误",
                          @"198" : @"请求类型错误，例如在注册申请发出后未发注册请求而发了其它请求",
                          @"199" : @"未知错误"
                          };
    NSString *key = [NSString stringWithFormat:@"%ld",code];
    if (!dic[key]) {
        return @"";
    }
    return dic[key];
}
@end
