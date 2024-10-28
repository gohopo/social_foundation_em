package com.gohopo.social_foundation_em.push;

import android.content.Context;
import android.os.Build;

import com.heytap.msp.push.HeytapPushManager;
import com.hihonor.push.sdk.HonorPushClient;
import com.huawei.hms.push.HmsMessaging;

public class PushManager {
  public static void registerPush(Context context){
    String brand = Build.BRAND;
    //荣耀
    if(HonorPushClient.getInstance().checkSupportHonorPush(context)){
      HonorPushClient.getInstance().init(context, true);
    }
    else if(brand.equalsIgnoreCase("huawei")){
      HmsMessaging.getInstance(context).setAutoInitEnabled(true);
    }
    else if(HeytapPushManager.isSupportPush(context)){
      HeytapPushManager.init(context, true);
    }
  }
}