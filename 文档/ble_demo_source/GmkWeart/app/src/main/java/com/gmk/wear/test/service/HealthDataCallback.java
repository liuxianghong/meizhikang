package com.gmk.wear.test.service;

/**
 *  * 底层数据回调接口，由于jni底层通过一线程维护回调，请勿在回调接口内做耗时操作
 * Created by numb on 2015/11/24.
 */
public interface HealthDataCallback {
    //底层回复ok
    public void onOk(int value);

    /**
     * hrv 回调
     * @param hrvValue hrv值
     * @param flag flag
     */
    public void onHrv(int hrvValue,int flag);

    /**
     *acc 回调
     * @param maxAcc 半分钟最大acc值
     * @param avgAcc 半分钟平均最大acc值
     */
    public void onAcc(int maxAcc,int avgAcc);

    /**
     * 心率值回调
     * @param hr 心率值
     */
    public void onHr(int hr);

    /**
     * 分平均心率回调
     * @param avgHr 分平均心率值
     */
    public void onAvgHr(int avgHr);

    /**
     * 睡眠参考心率回调
     * @param sleepHr 睡眠参考心率值
     */
    public void onSleepHr(int sleepHr);
}
