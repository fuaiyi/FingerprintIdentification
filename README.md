## iOS 指纹验证(Touch ID)
iOS的指纹识别是一个非常简单的api系统已经封好了,直接调起就行,非常简单,苹果的一贯作风,我们除了结果什么也拿不到,就一个bool结果和一个error,这里给一些比较懒的同学贴一下代码



##### 指纹验证


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
这里需要注意一下:
1. 验证类型有2种:一种是系统的密码(touchid被锁时需要调用),一种是指纹
2. 系统的密码验证和指纹识别实在子线程中进行的,我们在结果block的回调中如果要处理UI就要自己去回到主线程中去(系统不会帮我们回到主线程)



##### 错误结果处理:

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

这里需要注意:
错误类型LAErrorTouchIDLockout表示指纹验证错误次数上限,这时需要调起手机密码进行解锁touchid


Touch ID 的东西简单的就这些了,需要的同学拿去吧
本文Demo

