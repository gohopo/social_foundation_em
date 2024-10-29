package com.gohopo.social_foundation_em.push;

import android.util.Log;

import com.hihonor.push.sdk.HonorMessageService;
import com.hyphenate.chat.EMClient;

public class HonorPushService extends HonorMessageService {
    @Override
    public void onNewToken(String token){
        if(token != null && !token.isEmpty()){
            Log.d("HonorPush", "service register honor push token success token:" + token);
            EMClient.getInstance().sendHonorPushTokenToServer(token);
        }
        else{
            Log.e("HonorPush", "service register honor push token fail!");
        }
    }
}
