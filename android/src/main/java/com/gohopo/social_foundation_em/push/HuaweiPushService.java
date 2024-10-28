package com.gohopo.social_foundation_em.push;

import com.huawei.hms.push.HmsMessageService;
import com.hyphenate.chat.EMClient;
import com.hyphenate.util.EMLog;

public class HuaweiPushService extends HmsMessageService {
    @Override
    public void onNewToken(String token){
        if(token != null && !token.isEmpty()){
            EMLog.d("HuaweiPush", "service register huawei push token success token:" + token);
            EMClient.getInstance().sendHMSPushTokenToServer(token);
        }
        else{
            EMLog.e("HuaweiPush", "service register huawei push token fail!");
        }
    }
}
