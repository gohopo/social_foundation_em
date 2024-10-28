package com.gohopo.social_foundation_em.push;

import com.hihonor.push.sdk.HonorMessageService;
import com.hyphenate.chat.EMClient;
import com.hyphenate.util.EMLog;

public class HonorPushService extends HonorMessageService {
    @Override
    public void onNewToken(String token){
        if(token != null && !token.isEmpty()){
            EMLog.d("HonorPush", "service register honor push token success token:" + token);
            EMClient.getInstance().sendHonorPushTokenToServer(token);
        }
        else{
            EMLog.e("HonorPush", "service register honor push token fail!");
        }
    }
}
