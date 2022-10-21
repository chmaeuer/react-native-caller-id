
package de.propstack.callerid;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.utils.Constants;

import org.json.JSONArray;
import org.json.JSONObject;

import java.security.Permission;
import java.util.ArrayList;
import java.util.List;

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
    public void setCallerList(String callerListJson, final Promise promise) {
        try {
          SharedPreferences sharedPreferences = getReactApplicationContext().getSharedPreferences(Constants.CALLER_PREF_KEY, Context.MODE_PRIVATE);
          SharedPreferences.Editor editor = sharedPreferences.edit();
          editor.clear();

          JSONArray callerList = new JSONArray(callerListJson);
          
          for (int i = 0; i < callerList.length(); i++) {
              JSONObject caller = callerList.getJSONObject(i);
              Log.d("CALLER_ID", "Caller: " + String.valueOf(caller));
              String callerName = caller.getString("name");
              String callerNumber = caller.getString("number").replaceAll("-", "").replaceAll("\\(", "").replaceAll("\\)", "").replaceAll(" ", "");
              Log.d("CALLER_ID", "sanitized: " + callerNumber);
              editor.putString(callerNumber, callerName);
          }
          editor.apply();
          promise.resolve(true);
        } catch (Exception e) {
            Log.e("CALLER_ID", e.getLocalizedMessage());
            promise.reject(e.getMessage());
        }

    }

    private boolean isSystemAlertPermissionGranted(Context context) {
        return Settings.canDrawOverlays(context);
    }
    
    private List<String> getMissingTelephonyManagerPermissions() {
      List<String> listPermissionsNeeded = new ArrayList<>();
      int readCallLogPermission = ContextCompat.checkSelfPermission(reactContext, Manifest.permission.READ_CALL_LOG);
      if(readCallLogPermission != PackageManager.PERMISSION_GRANTED){
        listPermissionsNeeded.add(Manifest.permission.READ_CALL_LOG);
      }
      int readPhoneStatePermission = ContextCompat.checkSelfPermission(reactContext, Manifest.permission.READ_PHONE_STATE);
      if(readPhoneStatePermission != PackageManager.PERMISSION_GRANTED){
        listPermissionsNeeded.add(Manifest.permission.READ_PHONE_STATE);
      }
      return listPermissionsNeeded;
    }

    @ReactMethod
    public void requestOverlayPermission() {
        if (!isSystemAlertPermissionGranted(getReactApplicationContext())) {
            final String packageName = getReactApplicationContext() == null ? getReactApplicationContext().getPackageName() : getReactApplicationContext().getPackageName();
            final Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + packageName));
            getReactApplicationContext().startActivityForResult(intent, 1000, null);
        }
        else {
          ActivityCompat.requestPermissions(reactContext.getCurrentActivity(), getMissingTelephonyManagerPermissions().toArray(new String[0]), 0);
        }
    }

    @ReactMethod
    public void getExtensionEnabledStatus(final Promise promise) {
        Boolean isSystemAlertPermissionGranted = isSystemAlertPermissionGranted(getReactApplicationContext());
        promise.resolve(isSystemAlertPermissionGranted && getMissingTelephonyManagerPermissions().size() == 0);
    }

}