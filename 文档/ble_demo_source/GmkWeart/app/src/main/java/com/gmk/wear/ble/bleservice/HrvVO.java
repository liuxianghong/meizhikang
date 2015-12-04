package com.gmk.wear.ble.bleservice;
/**
 *
 * @author numb <br/>
 *create at 2014-11-7 上午10:21:31
 */
public class HrvVO
{
	public static final int UNHEALTHY = 0;// 不健康
	public static final int TIRED = 1;// 小恙或疲劳
	public static final int SUBHEALTHY = 2;// 亚健康
	public static final int HEALTHY = 3;// 健康
	private int score;//得分
	private int arrhythmiaFlag;//心率不齐标志
	private int helathFlag;//健康状态标志,值为UNHEALTHY，TIRED，SUBHEALTHY，HEALTHY中的一个
	private int lostCount;//测试使用
	private long recordTime;//记录时间

	public int getLostCount()
	{
		return lostCount;
	}

	public void setLostCount(int lostCount)
	{
		this.lostCount = lostCount;
	}

	public int getScore()
	{
		return score;
	}

	public void setScore(int score)
	{
		this.score = score;
	}

	public int getArrhythmiaFlag()
	{
		return arrhythmiaFlag;
	}

	public void setArrhythmiaFlag(int arrhythmiaFlag)
	{
		this.arrhythmiaFlag = arrhythmiaFlag;
	}

	public int getHelathFlag()
	{
		return helathFlag;
	}

	public void setHelathFlag(int helathFlag)
	{
		this.helathFlag = helathFlag;
	}

	public long getRecordTime()
	{
		return recordTime;
	}

	public void setRecordTime(long recordTime)
	{
		this.recordTime = recordTime;
	}

}
