//
//  SafeFingerprintViewController.m
//  demo
//
//  Created by gaofu on 2017/3/27.
//  Copyright © 2017年 siruijk. All rights reserved.
//
//  Abstract:指纹

#import "SafeFingerprintViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SafeFingerprintViewController ()

@end

@implementation SafeFingerprintViewController


#pragma mark -
#pragma mark  Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //调起指纹识别
    [self touchIDAction];
    
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -
#pragma mark  Interface Components



#pragma mark -
#pragma mark  Target Action Methods

- (IBAction)touchIDClick:(UIButton *)sender
{
    [self touchIDAction];
}



#pragma mark -
#pragma mark  Private Methods


- (void)touchIDAction
{
    //初始化上下文对象
    LAContext* context = [LAContext new];
    
    NSError* error = nil;
    NSString* result = @"通过Home键验证已有手机指纹";
    
    
    /*
     密码验证:
     LAPolicyDeviceOwnerAuthentication  手机数字密码
     LAPolicyDeviceOwnerAuthenticationWithBiometrics  手机指纹密码
     */
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
    {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error){
            if (success)
            {
                //识别是在子线程中进行的,这里如果用到UI操作就要到主线程进行操作
                NSLog(@"当前线程:%@",[NSThread currentThread]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"当前线程:%@",[NSThread currentThread]);
                    [self showMessage:@"验证成功!"];
                });
            }
            else
            {
                [self TouchIDResult:error.code];
            }
        }];
    }
    else
    {
        [self TouchIDResult:error.code];
    }
}



-(void)TouchIDResult:(LAError)code
{
    NSString *result = nil;
    
    switch (code)
    {
        case LAErrorAuthenticationFailed:
        {
            result = @"用户验证没有通过，比如提供了错误的手指的指纹";
            break;
        }
        case LAErrorUserCancel:
        {
            result = @"用户取消了Touch ID验证";
            break;
        }
        case LAErrorUserFallback:
        {
            result = @"用户不想进行Touch ID验证，想进行输入密码操作";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //用户选择输入密码，可以调起app自己的密码系统,也可调起手机的密码系统
                
            });
            break;
        }
        case LAErrorSystemCancel:
        {
            result = @"切换到其他APP,系统取消验证Touch ID";
            break;
        }
        case LAErrorPasscodeNotSet:
        {
            result = @"用户没有在设备Settings中设定密码";
            break;
        }
        case LAErrorTouchIDNotAvailable:
        {
            result = @"设备不支持Touch ID";
            break;
        }
        case LAErrorTouchIDNotEnrolled:
        {
            result = @"设备没有进行Touch ID 指纹注册";
            break;
        }
        case LAErrorTouchIDLockout:
        {
            result = @"touchid被锁";
            
            // 这里是验证错误次数上限了,touchid被锁,这时候需要调起系统的密码验证就行解锁touchid,不然touchid就不能使用了
            LAContext* context = [LAContext new];
            NSString* result = @"请输入手机密码";
            
            //LAPolicyDeviceOwnerAuthentication:手机密码验证
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:result reply:^(BOOL success, NSError *error){
                if (success)
                {
                    [self touchIDAction];
                }
                else
                {
                    [self TouchIDResult:error.code];
                }
            }];
        }
        case LAErrorAppCancel:
        {
            result = @"应用取消验证";
            break;
        }
        case LAErrorInvalidContext:
        {
            result = @"验证失效";
            break;
        }
    }
    
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessage:result];
    });
}



-(void)showMessage:(NSString*)message
{
    
    NSString *title = @"温馨提示";
    NSString *confirmTitle = @"确定";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}




@end
