'use strict';

import {NativeModules, Platform} from 'react-native';

const {RNCallerId: CallerId} = NativeModules;

export const setCallerList = (callerList) => {
  try {
    return CallerId.setCallerList(JSON.stringify(callerList));
  } catch (error) {
    throw error;
  }
};

export const openSettings = async () => {
  try {
    if (Platform.OS === 'ios') {
        return await CallerId.openSettings();
    }
    if (Platform.OS === 'android') {
      return await CallerId.requestOverlayPermission();
    }
    return
  } catch (error) {
    throw error;
  }
};

//iOS only
export const getExtensionEnabledStatus = async () => {
  try {
    return await CallerId.getExtensionEnabledStatus();
  } catch (error) {
    throw error;
  }
};