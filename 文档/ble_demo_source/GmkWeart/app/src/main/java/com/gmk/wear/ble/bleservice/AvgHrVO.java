package com.gmk.wear.ble.bleservice;

public class AvgHrVO {
	private int hrValue;
	private long recordTime;

	public AvgHrVO() {

	}

	public AvgHrVO(int hrValue, long recordTime) {
		this.hrValue = hrValue;
		this.recordTime = recordTime;
	}

	public int getHrValue() {
		return hrValue;
	}

	public void setHrValue(int hrValue) {
		this.hrValue = hrValue;
	}

	public long getRecordTime() {
		return recordTime;
	}

	public void setRecordTime(long recordTime) {
		this.recordTime = recordTime;
	}

}
