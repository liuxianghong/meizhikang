package com.gmk.wear.test.service;

import android.app.Activity;
import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattServer;
import android.bluetooth.BluetoothGattServerCallback;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Binder;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.os.ParcelUuid;
import android.util.Log;

import com.gmk.wear.ble.bleservice.AccVO;
import com.gmk.wear.ble.bleservice.AvgHrVO;
import com.gmk.wear.ble.bleservice.BleServiceIni;
import com.gmk.wear.ble.bleservice.HrvVO;
import com.gmk.wear.ble.bleservice.SleepHrVO;

import java.util.Date;
import java.util.LinkedList;
import java.util.Random;

public class BleService extends Service {
    private BluetoothManager mBluetoothManager;
    private HandlerThread handlerThread;
    private BleHandler mHandler;
    private volatile boolean notiSentLock = false;
    private BluetoothGattServer mBluetoothGattServer;
    private int connectState = BluetoothProfile.STATE_DISCONNECTED;
    private BluetoothLeAdvertiser mBluetoothLeAdvertiser;
    private final String TAG = "BLESERVICE";
    private int notiNum = 0;
    private BluetoothDevice connectDevce = null;
    private Handler mMainHandler = null;
    private final byte COMMAND_RESET_STATUS_SENSORS = 0x01;
    private final byte COMMAND_RESTART_DEVICE = 0x02;
    private final byte COMMAND_RESET_STATUS_VALUE = 0x04;
    private final byte COMMAND_RESET_HRV = 0x08;
    private final byte COMMAND_SYNC_TIME = 0x10;
    private final byte COMMAND_NOTIFY_SET = 0x20;

    private final byte WARNING_NOTI_SET = 0x01;
    private final byte HR_NOTI_SET= 0x02;
    private final byte RR_NOTI_SET =0x04;
    private final byte SETUP_NOTI_SET= 0x08;
    private final byte BATT_NOTI_SET =0x10;
    private final byte HRV_NOTI_SET= 0x20;
    private final byte ACC_NOTI_SET =0x40;
    private final byte AVG_HR_NOTI_SET =(byte)0x80;
    private boolean isAvd = false;
    private NotifyTye notifyType = NotifyTye.NOTIFY_INVALID;
    private final int HANDLER_COMMAND_NOTIFY_SUCCESS = 1;
    private final int HANDLER_COMMAND_NOTIFY_CHECK = HANDLER_COMMAND_NOTIFY_SUCCESS + 1;
    private final int HANDLER_COMMAND_ADD_ACC = HANDLER_COMMAND_NOTIFY_CHECK + 1;
    private final int HANDLER_COMMAND_ADD_AVG_HR = HANDLER_COMMAND_ADD_ACC + 1;
    private final int HANDLER_COMMAND_ADD_HRV = HANDLER_COMMAND_ADD_AVG_HR + 1;
    private final int HANDLER_COMMAND_ADD_SLEEP_HR = HANDLER_COMMAND_ADD_HRV + 1;

    private final Integer NOTIFY_LOCK =  Integer.valueOf(0);

    public class LocalBinder extends Binder {
        public BleService getService() {
            return BleService.this;
        }
    }

    private final IBinder mBinder = new LocalBinder();

    private enum NotifyTye {
        NOTIFY_INVALID,
        NOTIFY_HR,
        NOTIFY_HRV,
        NOTIFY_AVG_HR,
        NOTIFY_ACC,
        NOTIFY_SLEEP_HR
    }

    private class BleHandler extends Handler {
        private LinkedList<Integer> heartRateCache = new LinkedList<Integer>();
        private final int MAX_CACHE_SIZE = 2;
        private int lastNotifyCheckType = 0;
        private DataPtrController dataPtrController;

        public void addHr(int hr) {
            if (heartRateCache.size() == MAX_CACHE_SIZE) {
                heartRateCache.poll();
            }
            heartRateCache.addLast(hr);
            this.obtainMessage(HANDLER_COMMAND_NOTIFY_CHECK).sendToTarget();
        }

        public BleHandler(Looper looper) {
            super(looper);
            dataPtrController=new DataPtrController(getApplicationContext());

        }

        /**
         * ACC 通知
         * @return
         */
        private boolean notifyAcc() {
            if (connectState == BluetoothProfile.STATE_CONNECTED) {
                final BluetoothDevice device = connectDevce;
                BluetoothGattCharacteristic mBluetoothGattCharacteristic = mBluetoothGattServer.getService(BleServiceIni.GMK_SERVICE_UUID).getCharacteristic(BleServiceIni.GMK_VALUE_CHARACTERISTIC_UUID);
                byte[] accBytes = new byte[8];
                HealthDatabase db = new HealthDatabase(getApplicationContext());
                AccVO acc = db.getAcc(dataPtrController.getAccSendRowId());
                accBytes[0] = 0x02;
                accBytes[1] = 0x03;
                accBytes[2] = (byte) acc.getMaxAcc();
                accBytes[3] = (byte) acc.getAvgAcc();
                byte[] timeBytes = ByteUtil.intToByteLittle((int) (acc.getRecordTime() / 1000), 4);
                System.arraycopy(timeBytes, 0, accBytes, 4, 4);
                mBluetoothGattCharacteristic.setValue(accBytes);
                return mBluetoothGattServer.notifyCharacteristicChanged(device, mBluetoothGattCharacteristic, true);
            }
            return false;
        }
        /**
         * HRV 通知
         * @return
         */
        private boolean notifyHrv() {
            if (connectState == BluetoothProfile.STATE_CONNECTED) {
                final BluetoothDevice device = connectDevce;
                BluetoothGattCharacteristic mBluetoothGattCharacteristic = mBluetoothGattServer.getService(BleServiceIni.GMK_SERVICE_UUID).getCharacteristic(BleServiceIni.GMK_VALUE_CHARACTERISTIC_UUID);
                byte[] accBytes = new byte[8];
                HealthDatabase db = new HealthDatabase(getApplicationContext());
                AccVO acc = db.getAcc(dataPtrController.getAccSendRowId());
                accBytes[0] = 0x02;
                accBytes[1] = 0x03;
                accBytes[2] = (byte) acc.getMaxAcc();
                accBytes[3] = (byte) acc.getAvgAcc();
                byte[] timeBytes = ByteUtil.intToByteLittle((int) (acc.getRecordTime() / 1000), 4);
                System.arraycopy(timeBytes, 0, accBytes, 4, 4);
                mBluetoothGattCharacteristic.setValue(accBytes);
                return mBluetoothGattServer.notifyCharacteristicChanged(device, mBluetoothGattCharacteristic, true);
            }
            return false;
        }
        /**
         * avghr 通知
         * @return
         */
        private boolean notifyAvgHr() {
            if (connectState == BluetoothProfile.STATE_CONNECTED) {
                final BluetoothDevice device = connectDevce;
                BluetoothGattCharacteristic mBluetoothGattCharacteristic = mBluetoothGattServer.getService(BleServiceIni.GMK_SERVICE_UUID).getCharacteristic(BleServiceIni.GMK_VALUE_CHARACTERISTIC_UUID);
                byte[] avgHrBytes = new byte[6];
                HealthDatabase db = new HealthDatabase(getApplicationContext());
                AvgHrVO avgHr = db.getAvgHr(dataPtrController.getAvgHrSendRowId());
                avgHrBytes[0] = 0x03;
                avgHrBytes[1] = (byte) avgHr.getHrValue();
                byte[] timeBytes = ByteUtil.intToByteLittle((int) (avgHr.getRecordTime() / 1000), 4);
                System.arraycopy(timeBytes, 0, avgHrBytes, 2, 4);
                mBluetoothGattCharacteristic.setValue(avgHrBytes);
                return mBluetoothGattServer.notifyCharacteristicChanged(device, mBluetoothGattCharacteristic, true);
            }
            return false;
        }
        /**
         * sleep hr 通知
         * @return
         */
        private boolean notifySleepHr() {
            if (connectState == BluetoothProfile.STATE_CONNECTED) {
                final BluetoothDevice device = connectDevce;
                BluetoothGattCharacteristic mBluetoothGattCharacteristic = mBluetoothGattServer.getService(BleServiceIni.GMK_SERVICE_UUID).getCharacteristic(BleServiceIni.GMK_VALUE_CHARACTERISTIC_UUID);
                byte[] sleepHrBytes = new byte[7];
                HealthDatabase db = new HealthDatabase(getApplicationContext());
                SleepHrVO sleepHrVO = db.getSleepHr(dataPtrController.getSleepHrSendRowId());
                sleepHrBytes[0] = 0x05;
                sleepHrBytes[1] = 0x02;
                sleepHrBytes[2] = (byte) sleepHrVO.getHr();
                byte[] timeBytes = ByteUtil.intToByteLittle((int) (sleepHrVO.getRecordTime() / 1000), 4);
                System.arraycopy(timeBytes, 0, sleepHrBytes, 3, 4);
                mBluetoothGattCharacteristic.setValue(sleepHrBytes);
                return mBluetoothGattServer.notifyCharacteristicChanged(device, mBluetoothGattCharacteristic, true);
            }
            return false;
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case HANDLER_COMMAND_NOTIFY_SUCCESS:
                    if (notifyType == NotifyTye.NOTIFY_ACC) {
                        dataPtrController.accDataPtrPlus(DataPtrController.PtrType.SEND_PTR);
                    } else if (notifyType == NotifyTye.NOTIFY_AVG_HR) {
                        dataPtrController.avgHrDataPtrPlus(DataPtrController.PtrType.SEND_PTR);
                    } else if (notifyType == NotifyTye.NOTIFY_HRV) {
                        dataPtrController.hrvDataPtrPlus(DataPtrController.PtrType.SEND_PTR);
                    } else if (notifyType == NotifyTye.NOTIFY_SLEEP_HR) {
                        dataPtrController.sleepHrDataPtrPlus(DataPtrController.PtrType.SEND_PTR);
                    }
                    notifyType = NotifyTye.NOTIFY_INVALID;
                case HANDLER_COMMAND_NOTIFY_CHECK: {
                    synchronized (NOTIFY_LOCK) {
                        if (notifyType != NotifyTye.NOTIFY_INVALID) {
                            return;
                        }
                    }
                    /**
                     * 首先检查推送心率
                     */
                    if (heartRateCache.size() != 0) {
                        if (notifyHeartRate(heartRateCache.peek())) {
                            heartRateCache.poll();
                            notifyType = NotifyTye.NOTIFY_HR;
                        }
                        return;
                    }
                    /**
                     * 循环检查推送 ACC AVGHR HRV SLEEPHR
                     */
                    int upCheckNum = lastNotifyCheckType;
                    for (; lastNotifyCheckType - upCheckNum < 4; lastNotifyCheckType++) {
                        switch (lastNotifyCheckType % 4) {
                            case 0:
                                //检查acc
                                if (dataPtrController.isHaveAccSendData()) {
                                    if (notifyAcc()) {
                                        notifyType = NotifyTye.NOTIFY_ACC;
                                    }
                                    lastNotifyCheckType++;
                                    return;
                                }
                                break;
                            case 1:
                                //检查avghr
                                if (dataPtrController.isHaveAvgHrSendData()) {
                                    if (notifyAvgHr()) {
                                        notifyType = NotifyTye.NOTIFY_AVG_HR;
                                    }
                                    lastNotifyCheckType++;
                                    return;
                                }
                                break;
                            case 2:
                                //检查hrv
                                if (dataPtrController.isHaveHrvSendData()) {
                                    if (notifyHrv()) {
                                        notifyType = NotifyTye.NOTIFY_HRV;
                                    }
                                    lastNotifyCheckType++;
                                    return;
                                }
                                break;
                            case 3:
                                //检查sleephr
                                if (dataPtrController.isHaveSleepHrSendData()) {
                                    if (notifySleepHr()) {
                                        notifyType = NotifyTye.NOTIFY_SLEEP_HR;
                                    }
                                    lastNotifyCheckType++;
                                    return;
                                }
                                break;
                        }
                    }
                }
                break;
                case HANDLER_COMMAND_ADD_ACC: {
                    HealthDatabase db = new HealthDatabase(getApplicationContext());
                    long rowid = db.addAcc((AccVO) msg.obj);
                    if (rowid != -1) {
                        dataPtrController.accDataPtrPlus(DataPtrController.PtrType.MAX_PTR);
                    }
                    this.obtainMessage(HANDLER_COMMAND_NOTIFY_CHECK).sendToTarget();
                }
                break;
                case HANDLER_COMMAND_ADD_AVG_HR: {
                    HealthDatabase db = new HealthDatabase(getApplicationContext());
                    long rowid = db.addAvgHr((AvgHrVO) msg.obj);
                    if (rowid != -1) {
                        dataPtrController.avgHrDataPtrPlus(DataPtrController.PtrType.MAX_PTR);
                    }
                    this.obtainMessage(HANDLER_COMMAND_NOTIFY_CHECK).sendToTarget();

                }
                break;
                case HANDLER_COMMAND_ADD_HRV: {
                    HealthDatabase db = new HealthDatabase(getApplicationContext());
                    long rowid = db.addHrv((HrvVO) msg.obj);
                    if (rowid != -1) {
                        dataPtrController.hrvDataPtrPlus(DataPtrController.PtrType.MAX_PTR);
                    }
                    this.obtainMessage(HANDLER_COMMAND_NOTIFY_CHECK).sendToTarget();

                }
                break;
                case HANDLER_COMMAND_ADD_SLEEP_HR: {
                    HealthDatabase db = new HealthDatabase(getApplicationContext());
                    long rowid = db.addSleepHr((SleepHrVO) msg.obj);
                    if (rowid != -1) {
                        dataPtrController.sleepHrDataPtrPlus(DataPtrController.PtrType.MAX_PTR);
                    }
                    this.obtainMessage(HANDLER_COMMAND_NOTIFY_CHECK).sendToTarget();

                }
                break;
            }
        }
    }

    private AdvertiseCallback advertiseCallback = new AdvertiseCallback() {
        @Override
        public void onStartSuccess(AdvertiseSettings settingsInEffect) {
            super.onStartSuccess(settingsInEffect);
            isAvd = true;
            BleLog.i(TAG, "adv success");
        }

        @Override
        public void onStartFailure(int errorCode) {
            super.onStartFailure(errorCode);
            BleLog.i(TAG, errorCode + " onStartFailure");

        }

    };
    private HealthDataCallback dataCallback = new HealthDataCallback() {
        @Override
        public void onOk(int value) {
            Log.i(TAG, "onOk recvie");
        }

        @Override
        public void onHrv(int hrvValue, int flag) {
            HrvVO vo = new HrvVO();
            vo.setScore(hrvValue);
            vo.setHelathFlag(flag);
            vo.setRecordTime(System.currentTimeMillis());
            mHandler.obtainMessage(HANDLER_COMMAND_ADD_HRV, vo).sendToTarget();
        }

        @Override
        public void onAcc(int maxAcc, int avgAcc) {
            AccVO vo = new AccVO();
            vo.setAvgAcc(avgAcc);
            vo.setMaxAcc(maxAcc);
            vo.setRecordTime(System.currentTimeMillis());
            mHandler.obtainMessage(HANDLER_COMMAND_ADD_ACC, vo).sendToTarget();
        }

        @Override
        public void onHr(int hr) {
            mHandler.addHr(hr);
            mHandler.obtainMessage(HANDLER_COMMAND_NOTIFY_CHECK).sendToTarget();
        }

        @Override
        public void onAvgHr(int avgHr) {
            AvgHrVO vo = new AvgHrVO();
            vo.setRecordTime(System.currentTimeMillis());
            vo.setHrValue(avgHr);
            mHandler.obtainMessage(HANDLER_COMMAND_ADD_AVG_HR, vo).sendToTarget();
        }

        @Override
        public void onSleepHr(int sleepHr) {
            SleepHrVO vo = new SleepHrVO();
            vo.setHr(sleepHr);
            vo.setRecordTime(System.currentTimeMillis());
            mHandler.obtainMessage(HANDLER_COMMAND_ADD_SLEEP_HR, vo).sendToTarget();
        }
    };

    private boolean notifyHeartRate(int heartRate) {

        if (connectState == BluetoothProfile.STATE_CONNECTED) {
            final BluetoothDevice device = connectDevce;
            BluetoothGattCharacteristic mBluetoothGattCharacteristic = mBluetoothGattServer.getService(BleServiceIni.HEART_RATE_SERVICE_UUID).getCharacteristic(BleServiceIni.HEART_RATE_VALUE_CHARACTERISTIC_UUID);
            byte[] hrBytes = new byte[]{0, (byte) (heartRate & 0xff)};
            mBluetoothGattCharacteristic.setValue(hrBytes);
            return mBluetoothGattServer.notifyCharacteristicChanged(device, mBluetoothGattCharacteristic, true);
        }
        return false;
    }
    private void decodeAppCommand(byte[] value)
    {
        byte event=value[0];
        if((event&COMMAND_RESET_STATUS_SENSORS)!=0)
        {
           //重置
        }
        if((event&COMMAND_RESTART_DEVICE)!=0)
        {
           //重启手表
        }
        if((event&COMMAND_RESET_STATUS_VALUE)!=0)
        {

        }
        if((event&COMMAND_RESET_HRV)!=0)
        {
           //重置 hrv
        }
        if((event&COMMAND_SYNC_TIME)!=0)
        {
            //同步时间
           byte[] timeBytes=new byte[4];
           System.arraycopy(value,2,timeBytes,0,4);
            /**
             * 得到UTC 时间
             * 转化为java时间可为: Date time=new Date(timeSec*1000l);
             */
            int timeSec=ByteUtil.byteToInt(timeBytes);


        }
        if((event&COMMAND_NOTIFY_SET)!=0)
        {
            /*
            * 通知控制命令，实际为手机端需要哪些数据，
            * 现系统中获取的数据如下：
            * acc,(需做缓存，保证全部数据传输成功)
            * avghr(需做缓存，保证全部数据传输成功)
            * ,hrv,(需做缓存，保证全部数据传输成功)
            * sleephr(需做缓存，保证全部数据传输成功)
            * ,hr（即时心率）
            * 都是需要发往手机端的，所以可不根据此作为是否notify的依据
            * 手机端为了简化通讯步骤，此时就可以开始将数据notify给手机了，通过以下方法
            * ：            mHandler.obtainMessage(HANDLER_COMMAND_NOTIFY_CHECK).sendToTarget();
             */

            byte notiset=value[1];
            if((notiset&WARNING_NOTI_SET)!=0)
            {
            }
            if((notiset&HR_NOTI_SET)!=0)
            {
            }
            if((notiset&RR_NOTI_SET)!=0)
            {
            }
            if((notiset&SETUP_NOTI_SET)!=0)
            {
            }
            if((notiset&BATT_NOTI_SET)!=0)
            {
            }
            if((notiset&HRV_NOTI_SET)!=0)
            {
            }
            if((notiset&ACC_NOTI_SET)!=0){
            }
            if((notiset&AVG_HR_NOTI_SET)!=0)
            {

            }
        }
    }

    private BluetoothGattServerCallback mBluetoothGattServerCallback = new BluetoothGattServerCallback() {
        @Override
        public void onConnectionStateChange(BluetoothDevice device, int status, int newState) {
            super.onConnectionStateChange(device, status, newState);
            BleLog.i(TAG, "connect statechange" + newState + ";status= " + status);
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                notiNum = 0;
                stopAdvertising();
                connectDevce = device;
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                notiNum = 0;
                startAdvertising();
                connectDevce = null;
                isAvd = false;
            } else if (newState == BluetoothProfile.STATE_DISCONNECTING) {
            }
            connectState = newState;
        }

        @Override
        public void onServiceAdded(int status, BluetoothGattService service) {
            super.onServiceAdded(status, service);
            if (!isAvd) {
                isAvd=true;
                startAdvertising();
            }
        }

        @Override
        public void onCharacteristicReadRequest(BluetoothDevice device, int requestId, int offset, BluetoothGattCharacteristic characteristic) {
            super.onCharacteristicReadRequest(device, requestId, offset, characteristic);
        }

        @Override
        public void onCharacteristicWriteRequest(BluetoothDevice device, int requestId, BluetoothGattCharacteristic characteristic, boolean preparedWrite, boolean responseNeeded, int offset, byte[] value) {
            super.onCharacteristicWriteRequest(device, requestId, characteristic, preparedWrite, responseNeeded, offset, value);
            if (responseNeeded) {
                mBluetoothGattServer.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value);
            }
            if(characteristic.getUuid().equals(BleServiceIni.GMK_COMMAND_CHARACTERISTIC_UUID))
            {
                decodeAppCommand(value);
            }
        }

        @Override
        public void onDescriptorReadRequest(BluetoothDevice device, int requestId, int offset, BluetoothGattDescriptor descriptor) {
            super.onDescriptorReadRequest(device, requestId, offset, descriptor);
        }

        @Override
        public void onDescriptorWriteRequest(BluetoothDevice device, int requestId, BluetoothGattDescriptor descriptor, boolean preparedWrite, boolean responseNeeded, int offset, byte[] value) {
            super.onDescriptorWriteRequest(device, requestId, descriptor, preparedWrite, responseNeeded, offset, value);
            BleLog.i(TAG, "onDescriptorWriteRequest " + responseNeeded);
            if (responseNeeded) {
                mBluetoothGattServer.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value);
            }
        }

        @Override
        public void onExecuteWrite(BluetoothDevice device, int requestId, boolean execute) {
            super.onExecuteWrite(device, requestId, execute);
        }

        @Override
        public void onNotificationSent(BluetoothDevice device, int status) {
            super.onNotificationSent(device, status);
            Log.i(TAG, status + " onNotificationSent");
            if (status == BluetoothGatt.GATT_SUCCESS) {
                mHandler.obtainMessage(HANDLER_COMMAND_NOTIFY_SUCCESS).sendToTarget();
            } else {
                synchronized (NOTIFY_LOCK) {
                    notifyType = NotifyTye.NOTIFY_INVALID;
                }
            }
        }

        @Override
        public void onMtuChanged(BluetoothDevice device, int mtu) {
            super.onMtuChanged(device, mtu);
        }
    };

    public BleService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    /**
     * 开始广播
     */
    private void startAdvertising() {
        mBluetoothLeAdvertiser = mBluetoothManager.getAdapter().getBluetoothLeAdvertiser();
        AdvertiseData data = new AdvertiseData.Builder()
                .addServiceUuid(ParcelUuid.fromString(BleServiceIni.HRV_SERVICE_UUID.toString())).setIncludeDeviceName(true).build();
        AdvertiseSettings settings = new AdvertiseSettings.Builder().setConnectable(true).build();
        mBluetoothLeAdvertiser.startAdvertising(settings, data, advertiseCallback);
    }
    /**
     *结束广播
     */
    private void stopAdvertising() {
        mBluetoothManager.getAdapter().getBluetoothLeAdvertiser().stopAdvertising(advertiseCallback);
    }

    private Runnable openServerRunable = new Runnable() {
        @Override
        public void run() {
            mBluetoothGattServer = mBluetoothManager.openGattServer(getApplicationContext(), mBluetoothGattServerCallback);
            if (mBluetoothGattServer != null) {
                mBluetoothGattServer.addService(BleServiceIni.getHrvService());
                mBluetoothGattServer.addService(BleServiceIni.getGmkService());
                mBluetoothGattServer.addService(BleServiceIni.getDeviceInfoService());
                mBluetoothGattServer.addService(BleServiceIni.getHeartRateService());
            } else {
                BleLog.i(TAG, " mBluetoothGattServer get error");
                mHandler.post(reInitServerRunable);
            }
        }
    };
    private Runnable reInitServerRunable = new Runnable() {
        @Override
        public void run() {
            mBluetoothManager.getAdapter().disable();
            try {
                Thread.sleep(15000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            mBluetoothManager.getAdapter().enable();
            try {
                Thread.sleep(15000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            mMainHandler.post(openServerRunable);
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        handlerThread = new HandlerThread("Ble thread");
        handlerThread.start();
        /*
         * 加载数据库，因为该数据方法为自己 重写了 SQLiteOpenHelper
         * 以支持多线程：1线程写，其他线程读。需要启动是加载数据库
         * 如果不用此SQLiteOpenHelper 可不管
         */
        HealthDatabase db = new HealthDatabase(this);
        db.initDatabase();


        mHandler = new BleHandler(handlerThread.getLooper());
        BleLog.setLogHandler(mHandler, this);

        if (mBluetoothManager == null) {
            mBluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
            if (mBluetoothManager == null) {
                return;
            }
        }
        /**
         * 默认开启蓝牙
         */
        if(! mBluetoothManager.getAdapter().isEnabled()) {
            mBluetoothManager.getAdapter().enable();
        }
        /**
         * 因蓝牙每次广播出去mac地址可能会变，所以客户端采取通过
         * 设备名辩别重连对象。次段代码设置固定的广播设备名
         */
        SharedPreferences preferences = this.getSharedPreferences("per_devcie_num_file", Activity.MODE_PRIVATE);
        String devnum = preferences.getString("dev_num", "");
        if (devnum.equals("")) {
            Random random = new Random();
            devnum = Integer.toString(random.nextInt(10000));
            SharedPreferences.Editor editor = this.getSharedPreferences("per_devcie_num_file", Activity.MODE_PRIVATE).edit();
            editor.putString("dev_num", devnum);
            editor.apply();
        }
        mBluetoothManager.getAdapter().setName("GMK" + devnum);

        mMainHandler = new Handler();
        /*
        加载蓝牙服务，当所有服务都加载成功后开启广播
         */
        mBluetoothGattServer = mBluetoothManager.openGattServer(this, mBluetoothGattServerCallback);
        if (mBluetoothGattServer != null) {
            mBluetoothGattServer.addService(BleServiceIni.getHrvService());
            mBluetoothGattServer.addService(BleServiceIni.getGmkService());
            mBluetoothGattServer.addService(BleServiceIni.getDeviceInfoService());
            mBluetoothGattServer.addService(BleServiceIni.getHeartRateService());
        } else {
            mHandler.post(reInitServerRunable);
        }
        //startAdvertising();

        /**
         * 加载jni接口
         */
        Runnable setJni = new Runnable() {
            @Override
            public void run() {
                HealthDataConfig dataConfig = new HealthDataConfig();
                //设置回调接口
                dataConfig.setDataCallback(dataCallback);
                //开启与内核连接
                dataConfig.init();
            }
        };
        Log.i("", "");
        Thread thread = new Thread(setJni);
        thread.start();
    }

    public void chanageSensor() {
        HealthDataConfig dataConfig = new HealthDataConfig();

        if (dataConfig.checkLinkStatus() == 0) {
            dataConfig.openSensor();
        } else if (dataConfig.checkLinkStatus() == 1) {
            dataConfig.close();
        }
    }
}
