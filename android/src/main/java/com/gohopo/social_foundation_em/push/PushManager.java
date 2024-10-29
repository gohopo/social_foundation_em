package com.gohopo.social_foundation_em.push;

import android.app.Activity;
import android.os.Build;
import android.util.Log;

import com.heytap.msp.push.HeytapPushManager;
import com.hihonor.push.sdk.HonorPushClient;
import com.huawei.agconnect.AGConnectOptionsBuilder;
import com.huawei.hms.aaid.HmsInstanceId;
import com.huawei.hms.common.ApiException;
import com.huawei.hms.push.HmsMessaging;
import com.hyphenate.chat.EMClient;

public class PushManager {
  public static void registerPush(Activity activity){
    String brand = Build.BRAND;
    Log.d("PushManager","brand:"+brand);
    //荣耀
    if(HonorPushClient.getInstance().checkSupportHonorPush(activity)){
      Log.d("PushManager","is HonorPush");
      HonorPushClient.getInstance().init(activity, true);
    }
    else if(brand.equalsIgnoreCase("huawei")){
      Log.d("PushManager","is HuaweiPush");
      HmsMessaging.getInstance(activity).setAutoInitEnabled(true);
    }
    else if(HeytapPushManager.isSupportPush(activity)){
      Log.d("PushManager","is OppoPush");
      HeytapPushManager.init(activity, true);
    }
  }
  private void getHuaweiToken(Activity activity){
    new Thread(){
      @Override
      public void run(){
        try {
          String appId = new AGConnectOptionsBuilder().build(activity).getString("client/app_id");
          Log.d("PushManager","huawei appId:"+appId);
          String token = HmsInstanceId.getInstance(activity).getToken(appId, "HCM");
          Log.i("PushManager", "huawei token:"+token);
          if(token != null && !token.isEmpty()){
            EMClient.getInstance().sendHMSPushTokenToServer(token);
          }
        }
        catch (ApiException e) {
          Log.e("PushManager", "get huawei token failed, " + e);
        }
      }
    }.start();
  }
}