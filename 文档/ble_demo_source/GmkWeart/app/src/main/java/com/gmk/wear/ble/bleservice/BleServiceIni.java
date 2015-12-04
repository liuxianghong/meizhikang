package com.gmk.wear.ble.bleservice;

import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;

import java.util.UUID;

/**
 * 蓝牙 GATT 服务设置
 * Created by numb on 2015/11/23.
 */
public class BleServiceIni {
    public static  UUID CLIENT_CHARACTERISTIC_CONFIG=new UUID((0x2902L << 32) | 0x1000,
            0x800000805f9b34fbL);
    /**
     * hrv service
     */
    public static UUID HRV_SERVICE_UUID= new UUID((0x6802L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID HRV_CHARACTERISTIC_UUID= new UUID((0x9810L << 32) | 0x1000,
            0x800000805f9b34fbL);

    /**
     * GMK service
     */
    public static UUID GMK_SERVICE_UUID= new UUID((0x6801L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID GMK_VALUE_CHARACTERISTIC_UUID= new UUID((0x9801L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID GMK_COMMAND_CHARACTERISTIC_UUID= new UUID((0x9802L << 32) | 0x1000,
            0x800000805f9b34fbL);

    /**
     * heart_rate_service
     */
    public static UUID HEART_RATE_SERVICE_UUID= new UUID((0x180dL << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID HEART_RATE_VALUE_CHARACTERISTIC_UUID= new UUID((0x2a37L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID BODY_LOCATION_CHARACTERISTIC_UUID= new UUID((0x2a38L << 32) | 0x1000,
            0x800000805f9b34fbL);

    /**
     * device info service
     */
    public static UUID DEVICE_INFO_SERVICE_UUID= new UUID((0x180AL << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID DEVICE_INFO_SYSTEM_ID_CHARACTERISTIC_UUID= new UUID((0x2a23L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID DEVICE_INFO_MODEL_NUMBER_CHARACTERISTIC_UUID= new UUID((0x2a24L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID DEVICE_INFO_SERIAL_NUMBER_CHARACTERISTIC_UUID= new UUID((0x2a25L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID DEVICE_INFO_FIRMWARE_REV_CHARACTERISTIC_UUID= new UUID((0x2a26L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID DEVICE_INFO_HARDWARE_REV_CHARACTERISTIC_UUID= new UUID((0x2a27L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID DEVICE_INFO_SOFTWARE_REV_CHARACTERISTIC_UUID= new UUID((0x2a28L << 32) | 0x1000,
            0x800000805f9b34fbL);
    public static UUID DEVICE_INFO_MFR_NAME_CHARACTERISTIC_UUID= new UUID((0x2a29L << 32) | 0x1000,
            0x800000805f9b34fbL);


  public static BluetoothGattService getHrvService()
  {
      BluetoothGattService hrv=new BluetoothGattService( HRV_SERVICE_UUID,BluetoothGattService.SERVICE_TYPE_PRIMARY);
      BluetoothGattCharacteristic hrvCharacteristic=new BluetoothGattCharacteristic(HRV_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_INDICATE,BluetoothGattCharacteristic.PERMISSION_READ|BluetoothGattCharacteristic.PERMISSION_WRITE);
      BluetoothGattDescriptor mBluetoothGattDescriptor =new  BluetoothGattDescriptor(CLIENT_CHARACTERISTIC_CONFIG,BluetoothGattDescriptor.PERMISSION_WRITE|BluetoothGattDescriptor.PERMISSION_READ);
      hrvCharacteristic.addDescriptor(mBluetoothGattDescriptor);
      hrv.addCharacteristic(hrvCharacteristic);
      return hrv;
  }
    public static BluetoothGattService getHeartRateService()
    {
        BluetoothGattService hrService=new BluetoothGattService( HEART_RATE_SERVICE_UUID,BluetoothGattService.SERVICE_TYPE_PRIMARY);
        BluetoothGattCharacteristic heartRateCharacteristic=new BluetoothGattCharacteristic(HEART_RATE_VALUE_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_NOTIFY,BluetoothGattCharacteristic.PERMISSION_READ);
        BluetoothGattDescriptor mHeartRateGattDescriptor =new  BluetoothGattDescriptor(CLIENT_CHARACTERISTIC_CONFIG,BluetoothGattDescriptor.PERMISSION_WRITE|BluetoothGattDescriptor.PERMISSION_READ);
        heartRateCharacteristic.addDescriptor(mHeartRateGattDescriptor);
        BluetoothGattCharacteristic bodyLocationCharacteristic=new BluetoothGattCharacteristic(BODY_LOCATION_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        hrService.addCharacteristic(heartRateCharacteristic);
        bodyLocationCharacteristic.setValue(new byte[]{0x00});
        hrService.addCharacteristic(bodyLocationCharacteristic);
        return hrService;
    }
    public static BluetoothGattService getGmkService()
    {
        BluetoothGattService gmkService=new BluetoothGattService( GMK_SERVICE_UUID,BluetoothGattService.SERVICE_TYPE_PRIMARY);
        BluetoothGattCharacteristic gmkCharacteristic=new BluetoothGattCharacteristic(GMK_VALUE_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_INDICATE|BluetoothGattCharacteristic.PROPERTY_WRITE,BluetoothGattCharacteristic.PERMISSION_READ|BluetoothGattCharacteristic.PERMISSION_WRITE);
        BluetoothGattDescriptor gmkDescriptor =new  BluetoothGattDescriptor(CLIENT_CHARACTERISTIC_CONFIG,BluetoothGattDescriptor.PERMISSION_WRITE|BluetoothGattDescriptor.PERMISSION_READ);
        gmkCharacteristic.addDescriptor(gmkDescriptor);
        BluetoothGattCharacteristic gmkCommandCharacteristic=new BluetoothGattCharacteristic(GMK_COMMAND_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_WRITE,BluetoothGattCharacteristic.PERMISSION_WRITE);
        gmkService.addCharacteristic(gmkCharacteristic);
        gmkService.addCharacteristic(gmkCommandCharacteristic);
        return gmkService;
    }
    public static BluetoothGattService getDeviceInfoService()
    {
        BluetoothGattService gmkService=new BluetoothGattService( DEVICE_INFO_SERVICE_UUID,BluetoothGattService.SERVICE_TYPE_PRIMARY);
        BluetoothGattCharacteristic firmwareRevCharacteristic=new BluetoothGattCharacteristic(DEVICE_INFO_FIRMWARE_REV_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        BluetoothGattCharacteristic hardwareRevCharacteristic=new BluetoothGattCharacteristic(DEVICE_INFO_HARDWARE_REV_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        BluetoothGattCharacteristic mfrNameCharacteristic=new BluetoothGattCharacteristic(DEVICE_INFO_MFR_NAME_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        BluetoothGattCharacteristic modelNumberCharacteristic=new BluetoothGattCharacteristic(DEVICE_INFO_MODEL_NUMBER_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        BluetoothGattCharacteristic serialNumberCharacteristic=new BluetoothGattCharacteristic(DEVICE_INFO_SERIAL_NUMBER_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        BluetoothGattCharacteristic softwareRevCharacteristic=new BluetoothGattCharacteristic(DEVICE_INFO_SOFTWARE_REV_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        BluetoothGattCharacteristic systemIdCharacteristic=new BluetoothGattCharacteristic(DEVICE_INFO_SYSTEM_ID_CHARACTERISTIC_UUID,BluetoothGattCharacteristic.PROPERTY_READ,BluetoothGattCharacteristic.PERMISSION_READ);
        gmkService.addCharacteristic(firmwareRevCharacteristic);
        gmkService.addCharacteristic(hardwareRevCharacteristic);
        gmkService.addCharacteristic(mfrNameCharacteristic);
        gmkService.addCharacteristic(modelNumberCharacteristic);
        gmkService.addCharacteristic(serialNumberCharacteristic);
        gmkService.addCharacteristic(softwareRevCharacteristic);
        gmkService.addCharacteristic(systemIdCharacteristic);
        softwareRevCharacteristic.setValue("v2.0.0");
        return gmkService;
    }
}
