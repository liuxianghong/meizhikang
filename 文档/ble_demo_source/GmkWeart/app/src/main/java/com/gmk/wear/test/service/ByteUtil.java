/**
 * 
 */
package com.gmk.wear.test.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * @author numb
 */
public class ByteUtil
{
	public byte[] byteArraycat(byte[] buf1, byte[] buf2)
	{
		byte[] bufret = null;
		int len1 = 0, len2 = 0;
		if (buf1 != null)
		{
			len1 = buf1.length;
		}
		if (buf2 != null)
		{
			len2 = buf2.length;
		}
		if (len1 + len2 > 0)
		{
			bufret = new byte[len1 + len2];
		}
		if (len1 > 0)
		{
			System.arraycopy(buf1, 0, bufret, 0, len1);
		}
		if (len2 > 0)
		{
			System.arraycopy(buf2, 0, bufret, len1, len2);
		}
		return bufret;
	}

	public byte[] byteArrayspilt(byte[] srcBuf, int offSet, int len)
	{
		byte[] destBuf = null;
		if (srcBuf.length == 0)
		{
			return destBuf;
		}
		if (len > 0)
		{
			destBuf = new byte[len];
			System.arraycopy(srcBuf, offSet, destBuf, 0, len);
		}
		return destBuf;
	}

	/**
	 * 整型转成byte数组(高位) 小端：数据低位放在低地址，数据高位放在高地址 0x12345678存放之后:0x78,0x56,0x34.0x12
	 * 
	 * @param intSrc
	 * @param length
	 * @return
	 */
	public static byte[] intToByteLittle(int intSrc, int length)
	{
		int countTemp = length - 1;
		int constNum8 = 8;

		byte[] byteDest = new byte[length];

		for (int i = 0; i < length; i++)
		{
			byteDest[length - i - 1] = (byte) ((intSrc >> countTemp * constNum8) & 0xFF);
			countTemp--;
		}
		return byteDest;
	}

	/**
	 * 整型转成byte数组(低位) 大端:高位存在低地�?，低位存在高地址 0x12345678存放之后�?:0x12,0x34,0x56,0x78
	 * 
	 * @param intSrc
	 * @param length
	 * @return
	 */
	public byte[] intToByteBig(int intSrc, int length)
	{
		int countTemp = length - 1;
		int constNum8 = 8;
		byte[] byteDest = new byte[length];

		for (int i = 0; i < length; i++)
		{
			byteDest[i] = (byte) ((intSrc >> countTemp * constNum8) & 0xFF);
			countTemp--;
		}
		return byteDest;
	}

	/**
	 * 字符串转成byte数组
	 * 
	 * @param str
	 * @param length
	 * @return
	 */
	public byte[] strToByte(String str, int length)
	{
		byte[] byte0;
		byte[] byte1;
		byte[] byteDest = new byte[length];

		if (length == 0)
		{
			return byteDest;
		}

		StringBuilder sb = new StringBuilder();
		try
		{
			byte0 = str.getBytes("UTF-8");
			for (byte element : byte0)
			{
				sb.append(element);
			}

			int byte0Count = sb.toString().length();
			if (length > byte0Count)
			{
				byte1 = new byte[length - byte0Count];

				for (int i = 0; i < byte1.length; i++)
				{
					byte1[i] = (byte) ((0 >> 0) & 0xFF);
				}

				System.arraycopy(byte0, 0, byteDest, 0, byte0.length);
				System.arraycopy(byte1, 0, byteDest, byte0.length, byte1.length);
			}
			else
			{
				System.arraycopy(byte0, 0, byteDest, 0, byte0.length);
			}
		}
		catch (UnsupportedEncodingException e)
		{
			e.printStackTrace();
		}
		return byteDest;
	}

	/**
	 * 字符串转成byte数组
	 * 
	 * @param str
	 * @return
	 */
	public byte[] strToByte(String str)
	{
		return str.getBytes();
	}

	/**
	 * byte[]转换成int�?
	 * 
	 * @param data 包括int的byte[]
	 * @param offset 偏移�?
	 * @return int�?
	 */
	public int bytesToInt(byte[] data, int offset)
	{
		int num = 0;
		for (int i = offset; i < offset + 4; i++)
		{
			num <<= 8;
			num |= (data[i] & 0xff);
		}
		return num;
	}

	/**
	 * byte[]转换成int
	 * 
	 * @param data 包括int的byte[]
	 * @param offset 偏移�?
	 * @return int�?
	 */
	public int bytesToShort(byte[] data, int offset)
	{
		int num = 0;
		for (int i = offset; i < offset + 2; i++)
		{
			num <<= 8;
			num |= (data[i] & 0xff);
		}
		return num;
	}

	/**
	 * 
	 * 
	 * @param byte0
	 * @return
	 */
	public static int byteToInt(byte[] byte0)
	{
		int len = byte0.length;
		int targets = 0;
		if (len == 1)
		{
			targets = (byte0[0] & 0xff);
		}
		else if (len == 2)
		{
			targets = (byte0[0] & 0xff) | ((byte0[1] << 8) & 0xff00);
		}
		else if (len == 3)
		{
			targets = (byte0[0] & 0xff) | ((byte0[1] << 8) & 0xff00) | ((byte0[2] << 24) >>> 8);
		}
		else if (len == 4)
		{
			targets = (byte0[0] & 0xff) | ((byte0[1] << 8) & 0xff00) | ((byte0[2] << 24) >>> 8) | (byte0[3] << 24);
		}
		return targets;
	}
}
