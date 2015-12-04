package com.gmk.wear.ble.bleservice;
/**
 * @author numb
 */
public class AccVO {
   private int maxAcc;//分最大acc
   private int avgAcc;//前半分钟平均acc

	private long recordTime;//记录时间

public int getMaxAcc() {
	return maxAcc;
}
public void setMaxAcc(int maxAcc) {
	this.maxAcc = maxAcc;
}
public int getAvgAcc() {
	return avgAcc;
}
public void setAvgAcc(int avgAcc) {
	this.avgAcc = avgAcc;
}
public long getRecordTime() {
	return recordTime;
}
public void setRecordTime(long recordTime) {
	this.recordTime = recordTime;
}
   
}
