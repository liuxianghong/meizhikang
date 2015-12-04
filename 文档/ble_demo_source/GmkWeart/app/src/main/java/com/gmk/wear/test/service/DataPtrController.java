package com.gmk.wear.test.service;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;

import java.util.Random;

/**
 * Created by numb on 2015/12/3.
 */
public class DataPtrController {
    public enum PtrType {
        SEND_PTR,
        MAX_PTR
    }
    private Context mContext;

    public DataPtrController(Context context) {
        mContext = context;
    }

    private final String ACC_SEND_PTR = "ACC_SEND_PTR";
    private final String HRV_SEND_PTR = "HRV_SEND_PTR";
    private final String AVG_HR_SEND_PTR = "AVG_HR_SEND_PTR";
    private final String SLEEP_HR_SEND_PTR = "SLEEP_HR_SEND_PTR";
    private final String ACC_MAX_PTR = "ACC_HR_MAX_PTR";
    private final String HRV_MAX_PTR = "HRV_MAX_PTR";
    private final String AVG_HR_MAX_PTR = "AVG_HR_MAX_PTR";
    private final String SLEEP_HR_MAX_PTR = "SLEEP_HR_MAX_PTR";

    public long getAccSendRowId()
    {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        return preferences.getLong(ACC_SEND_PTR, 1);
    }
    public long getHrvSendRowId()
    {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        return preferences.getLong(HRV_SEND_PTR, 1);
    }
    public long getAvgHrSendRowId()
    {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        return preferences.getLong(AVG_HR_SEND_PTR, 1);
    }
    public long getSleepHrSendRowId()
    {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        return preferences.getLong(SLEEP_HR_SEND_PTR, 1);
    }
    public boolean isHaveAccSendData() {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long accSendPtr = preferences.getLong(ACC_SEND_PTR, 1);
        long accMaxPtr = preferences.getLong(ACC_MAX_PTR, 1);
        if (accSendPtr < accMaxPtr) {
            return true;
        } else {
            return false;
        }
    }

    public boolean isHaveHrvSendData() {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long hrvSendPtr = preferences.getLong(HRV_SEND_PTR, 1);
        long hrvMaxPtr = preferences.getLong(HRV_MAX_PTR, 1);
        if (hrvSendPtr < hrvMaxPtr) {
            return true;
        } else {
            return false;
        }
    }

    public boolean isHaveAvgHrSendData() {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long avgHrSendPtr = preferences.getLong(AVG_HR_SEND_PTR, 1);
        long avgHrMaxPtr = preferences.getLong(AVG_HR_MAX_PTR, 1);
        if (avgHrSendPtr < avgHrMaxPtr) {
            return true;
        } else {
            return false;
        }
    }

    public boolean isHaveSleepHrSendData() {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long sleepHrSendPtr = preferences.getLong(SLEEP_HR_SEND_PTR, 1);
        long sleepHrMaxPtr = preferences.getLong(SLEEP_HR_MAX_PTR, 1);
        if (sleepHrSendPtr < sleepHrMaxPtr) {
            return true;
        } else {
            return false;
        }
    }

    public void accDataPtrPlus(PtrType ptrType) {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long accSendPtr = preferences.getLong(ACC_SEND_PTR, 1);
        long accMaxPtr = preferences.getLong(ACC_MAX_PTR, 1);
        SharedPreferences.Editor editor = preferences.edit();
        if (ptrType == PtrType.SEND_PTR) {
            accSendPtr = accSendPtr + 1 > accMaxPtr ? accSendPtr : accSendPtr + 1;
            editor.putLong(ACC_SEND_PTR,accSendPtr);
            editor.putLong(ACC_MAX_PTR,accMaxPtr);
        } else if (ptrType == PtrType.MAX_PTR) {
            accMaxPtr++;
            editor.putLong(ACC_MAX_PTR,accMaxPtr);
        }
        editor.commit();
    }

    public void hrvDataPtrPlus(PtrType ptrType) {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long hrvSendPtr = preferences.getLong(HRV_SEND_PTR, 1);
        long hrvMaxPtr = preferences.getLong(HRV_MAX_PTR, 1);
        SharedPreferences.Editor editor = preferences.edit();
        if (ptrType == PtrType.SEND_PTR) {
            hrvSendPtr = hrvSendPtr + 1 > hrvMaxPtr ? hrvSendPtr : hrvSendPtr + 1;
            editor.putLong(HRV_SEND_PTR,hrvSendPtr);
            editor.putLong(HRV_MAX_PTR,hrvMaxPtr);
        } else if (ptrType == PtrType.MAX_PTR) {
            hrvMaxPtr++;
            editor.putLong(HRV_MAX_PTR,hrvMaxPtr);
        }
        editor.commit();
    }

    public void sleepHrDataPtrPlus(PtrType ptrType) {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long sleepHrSendPtr = preferences.getLong(SLEEP_HR_SEND_PTR, 1);
        long sleepHrMaxPtr = preferences.getLong(SLEEP_HR_MAX_PTR, 1);
        SharedPreferences.Editor editor = preferences.edit();

        if (ptrType == PtrType.SEND_PTR) {
            sleepHrSendPtr = sleepHrSendPtr + 1 > sleepHrMaxPtr ? sleepHrSendPtr : sleepHrSendPtr + 1;
            editor.putLong(SLEEP_HR_SEND_PTR,sleepHrSendPtr);
            editor.putLong(SLEEP_HR_MAX_PTR,sleepHrMaxPtr);
        } else if (ptrType == PtrType.MAX_PTR) {
            sleepHrMaxPtr++;
            editor.putLong(SLEEP_HR_MAX_PTR,sleepHrMaxPtr);
        }
        editor.commit();
    }

    public void avgHrDataPtrPlus(PtrType ptrType) {
        SharedPreferences preferences = mContext.getSharedPreferences("data_ptr_control", Activity.MODE_PRIVATE);
        long avgHrSendPtr = preferences.getLong(AVG_HR_SEND_PTR, 1);
        long avgHrMaxPtr = preferences.getLong(AVG_HR_MAX_PTR, 1);
        SharedPreferences.Editor editor = preferences.edit();
        if (ptrType == PtrType.SEND_PTR) {
            avgHrSendPtr = avgHrSendPtr + 1 > avgHrMaxPtr ? avgHrSendPtr : avgHrSendPtr + 1;
            editor.putLong(AVG_HR_SEND_PTR,avgHrSendPtr);
            editor.putLong(AVG_HR_MAX_PTR,avgHrMaxPtr);
        } else if (ptrType == PtrType.MAX_PTR) {
            avgHrMaxPtr++;
            editor.putLong(AVG_HR_MAX_PTR,avgHrMaxPtr);
        }
        editor.commit();
    }
}
