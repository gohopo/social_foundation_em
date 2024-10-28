# social_foundation_em

## 推送

### AndroidManifest.xml

#### 荣耀

```xml
<!-- 荣耀推送 -->
<meta-data
    android:name="com.hihonor.push.app_id"
    android:value="${HONOR_PUSH_APPID}" />

<service
    android:name="com.gohopo.social_foundation_em.push.HonorPushService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.hihonor.push.action.MESSAGING_EVENT" />
    </intent-filter>
</service>
<!-- 荣耀推送 end -->
```

#### 华为

```xml
<!-- 华为推送 -->
<service android:name="com.gohopo.social_foundation_em.push.HuaweiPushService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.huawei.push.action.MESSAGING_EVENT" />
    </intent-filter>
</service>
<!-- 华为推送 end -->
```

#### 小米

```xml
<permission android:name="${PACKAGE_ID}.permission.MIPUSH_RECEIVE" android:protectionLevel="signature" />
<uses-permission android:name="${PACKAGE_ID}.permission.MIPUSH_RECEIVE" />
```

```xml
<!-- 小米推送 -->
<service
    android:name="com.xiaomi.push.service.XMPushService"
    android:enabled="true"
    android:process=":pushservice" />
<service
    android:name="com.xiaomi.push.service.XMJobService"
    android:enabled="true"
    android:exported="false"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:process=":pushservice" />
<service
    android:name="com.xiaomi.mipush.sdk.PushMessageHandler"
    android:enabled="true"
    android:exported="true"
    android:permission="com.xiaomi.xmsf.permission.MIPUSH_RECEIVE" />
<service
    android:name="com.xiaomi.mipush.sdk.MessageHandleService"
    android:enabled="true" />
<receiver
    android:name="com.xiaomi.push.service.receivers.NetworkStatusReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.net.conn.CONNECTIVITY_CHANGE" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</receiver>
<receiver
    android:name="com.xiaomi.push.service.receivers.PingReceiver"
    android:exported="false"
    android:process=":pushservice">
    <intent-filter>
        <action android:name="com.xiaomi.push.PING_TIMER" />
    </intent-filter>
</receiver>
<receiver android:name="com.gohopo.social_foundation_em.push.MiPushService" android:exported="true">
    <intent-filter>
        <action android:name="com.xiaomi.mipush.RECEIVE_MESSAGE" />
    </intent-filter>
    <intent-filter>
        <action android:name="com.xiaomi.mipush.MESSAGE_ARRIVED" />
    </intent-filter>
    <intent-filter>
        <action android:name="com.xiaomi.mipush.ERROR" />
    </intent-filter>
</receiver>
<!-- 小米推送 end -->
```

#### oppo

```xml
<uses-permission android:name="com.coloros.mcs.permission.RECIEVE_MCS_MESSAGE"/>
<uses-permission android:name="com.heytap.mcs.permission.RECIEVE_MCS_MESSAGE"/>
```

```xml
<!-- oppo推送 -->
<service
    android:name="com.heytap.msp.push.service.CompatibleDataMessageCallbackService"
    android:permission="com.coloros.mcs.permission.SEND_MCS_MESSAGE"
    android:exported="true">
    <intent-filter>
        <action android:name="com.coloros.mcs.action.RECEIVE_MCS_MESSAGE"/>
    </intent-filter>
</service> <!--兼容 Q 以下版本-->

<service
    android:name="com.heytap.msp.push.service.DataMessageCallbackService"
    android:permission="com.heytap.mcs.permission.SEND_PUSH_MESSAGE"
    android:exported="true">
    <intent-filter>
        <action android:name="com.heytap.mcs.action.RECEIVE_MCS_MESSAGE"/>
        <action android:name="com.heytap.msp.push.RECEIVE_MCS_MESSAGE"/>
    </intent-filter>
</service> <!--兼容 Q 版本-->
<!-- oppo推送 end -->
```

#### vivo

```xml
<!-- vivo推送 -->
<meta-data android:name="com.vivo.push.app_id" android:value="${app_id}"/>
<meta-data android:name="com.vivo.push.api_key" android:value="${api_key}"/>
<service
    android:name="com.vivo.push.sdk.service.CommandClientService"
    android:permission="com.push.permission.UPSTAGESERVICE"
    android:exported="true" />
<receiver android:name="com.hyphenate.push.platform.vivo.EMVivoMsgReceiver" android:exported="true">
    <intent-filter>
        <action android:name="com.vivo.pushclient.action.RECEIVE" />
    </intent-filter>
</receiver>
<!-- vivo推送 end -->
```
