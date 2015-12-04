package com.gmk.wear.test.service;

public class MzkLogVO
{

	private String level;
	private String tag;
	private String logtext;
	private String logtime;

	public MzkLogVO(String level, String tag, String logtext, String logtime)
	{
		this.level = level;
		this.tag = tag;
		this.logtext = logtext;
		this.logtime = logtime;
	}

	public String getLevel()
	{
		return level;
	}

	public void setLevel(String level)
	{
		this.level = level;
	}

	public String getTag()
	{
		return tag;
	}

	public void setTag(String tag)
	{
		this.tag = tag;
	}

	public String getLogtext()
	{
		return logtext;
	}

	public void setLogtext(String logtext)
	{
		this.logtext = logtext;
	}

	public String getLogtime()
	{
		return logtime;
	}

	public void setLogtime(String logtime)
	{
		this.logtime = logtime;
	}

}
