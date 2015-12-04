package com.gmk.wear.test.service;

/**
 * 底层jni接口，想要获取传感器数据，通过该jni注册回调接口获取
 * 操作步骤1：调用setDataCallback方法 ：设置回调接口
 *         2：调用init方法：加载与kernel连接
 *         3：等待数据回调
 *         4.......根据需求关闭和开启心率传感器
 * Created by numb on 2015/11/24.
 */
public class HealthDataConfig {
    static {
        System.loadLibrary("hdconfig");	//defaultConfig.ndk.moduleName
    }
    //设置底层数据回调接口，需优先于init()方法调用
    public native void setDataCallback(HealthDataCallback callback);
    //加载数据连接，必须次于setDataCallback调用，加载后底层数据通过callback接口回调开，只需调用一次
    public native boolean init();
    //开启心率传感器
    public native boolean openSensor();
    //关闭心率传感器
    public native boolean close();
    //退出jni
    public native boolean jniExit();
    //检查底层连接状态 -1：与底层连接处于断开状态，0：已连接单心率传感器未开启，1：已连接并且心率传感器已开启
    public native int checkLinkStatus();
}
