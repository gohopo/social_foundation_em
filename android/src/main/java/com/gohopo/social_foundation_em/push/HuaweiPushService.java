package com.gohopo.social_foundation_em.push;

import android.util.Log;

import com.huawei.hms.push.HmsMessageService;
import com.hyphenate.chat.EMClient;

public class HuaweiPushService extends HmsMessageService {
    @Override
    public void onNewToken(String token){
        if(token != null && !token.isEmpty()){
            Log.d("HuaweiPush", "service register huawei push token success token:" + token);
            EMClient.getInstance().sendHMSPushTokenToServer(token);
        }
        else{
            Log.e("HuaweiPush", "service register huawei push token fail!");
        }
    }
}
