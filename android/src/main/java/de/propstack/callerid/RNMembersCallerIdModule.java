
package de.propstack.callerid;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.provider.Settings;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.utils.Constants;

import org.json.JSONArray;
import org.json.JSONObject;

public class RNMembersCallerIdModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public RNMembersCallerIdModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNCallerId";
    }

    @ReactMethod
    public void setCallerList(String callerListJson) {
        try {
            SharedPreferences sharedPreferences = getReactApplicationContext().getSharedPreferences(Constants.CALLER_PREF_KEY, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.clear();

            JSONArray callerList = new JSONArray(callerListJson);
            
            for (int i = 0; i < callerList.length(); i++) {
                JSONObject caller = callerList.getJSONObject(i);
                Log.d("CALLER_ID", "Caller: " + String.valueOf(caller));
                String callerName = caller.getString("name");
                String callerNumber = caller.getString("number");
                editor.putString("+" + callerNumber, callerName);
            }
            editor.apply();
        } catch (Exception e) {
            Log.e("CALLER_ID", e.getLocalizedMessage());
        }

    }

    private boolean isSystemAlertPermissionGranted(Context context) {
        return Settings.canDrawOverlays(context);
    }

    @ReactMethod
    public void requestOverlayPermission() {
        if (!isSystemAlertPermissionGranted(getReactApplicationContext())) {
            final String packageName = getReactApplicationContext() == null ? getReactApplicationContext().getPackageName() : getReactApplicationContext().getPackageName();
            final Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + packageName));
            getReactApplicationContext().startActivityForResult(intent, 1000, null);
        }
    }

    @ReactMethod
    public void getExtensionEnabledStatus(final Promise promise) {
        promise.resolve(isSystemAlertPermissionGranted(getReactApplicationContext()));
    }

}