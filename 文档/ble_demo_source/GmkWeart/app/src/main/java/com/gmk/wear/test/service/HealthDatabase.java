package com.gmk.wear.test.service;


import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.gmk.wear.ble.bleservice.AccVO;
import com.gmk.wear.ble.bleservice.AvgHrVO;
import com.gmk.wear.ble.bleservice.HrvVO;
import com.gmk.wear.ble.bleservice.SleepHrVO;

/**
 * @author ncy
 */
public class HealthDatabase {
    private static final String TAG = "DxtDatabase";
    private static final String DATABASE_NAME = "healthdb";
    private static final int DATABASE_VERSION = 13;// 1,inint;2,add per device
    // table;3, add hrv
    // table;4add accValue
    // int;10 :add avghr //
    // status table.5:add acc
    // table6:add hrv loss_count
    // 9:add hrv2table
    private HealthDbHelper mDatabaseOpenHelper;
    public static final int UPDATE_HETERATE = 1;
    public static final int UPDATE_STATUS = 2;
    public static final int UPDATE_LOCATION = 3;
    public static final int UPDATE_ACC = 4;

    /**
     * Constructor
     *
     * @param context The Context within which to work, used to create the DB
     */
    public HealthDatabase(Context context) {
        if (mDatabaseOpenHelper == null) {
            mDatabaseOpenHelper = new HealthDbHelper(context);
        }
    }

    public void initDatabase() {
        mDatabaseOpenHelper.getWritableDatabase().close();
    }


    public void addLog(MzkLogVO logVO) {
        if (logVO == null) {
            return;
        }
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getWritableDatabase();
            ContentValues initialValues = new ContentValues();
            initialValues.put("loglevel", logVO.getLevel());
            initialValues.put("logtext", logVO.getLogtext());
            initialValues.put("logtag", logVO.getTag());
            initialValues.put("logdate", logVO.getLogtime());
            database.insert("mzklog", null, initialValues);

        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            if (database != null)
                database.close();
        }
    }

    public long addHrv(HrvVO hrvVO) {
        if (hrvVO == null) {
            return -1;
        }
        long re;
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getWritableDatabase();
            ContentValues initialValues = new ContentValues();
            initialValues.put("score", hrvVO.getScore());
            initialValues.put("arrhythmiaflag", hrvVO.getArrhythmiaFlag());
            initialValues.put("helathflag", hrvVO.getHelathFlag());
            initialValues.put("recordtime", hrvVO.getRecordTime());
            initialValues.put("lostcount", hrvVO.getLostCount());
            re = database.insert("hrv", null, initialValues);

        } catch (Exception exception) {
            re = -1;
        } finally {
            if (database != null) {
                database.close();
            }
        }
        return re;
    }

    public long addAvgHr(AvgHrVO avgHrVO) {
        if (avgHrVO == null) {
            return -1;
        }
        long re;
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getWritableDatabase();
            ContentValues initialValues = new ContentValues();
            initialValues.put("heartrate", avgHrVO.getHrValue());
            initialValues.put("recordtime", avgHrVO.getRecordTime());
            re = database.insert("avghr", null, initialValues);

        } catch (Exception exception) {
            re = -1;
            exception.printStackTrace();
        } finally {
            if (database != null) {
                database.close();
            }
        }
        return re;
    }

    public long addSleepHr(SleepHrVO sleepHrVO) {
        if (sleepHrVO == null) {
            return -1;
        }
        long re;

        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getWritableDatabase();
            ContentValues initialValues = new ContentValues();
            initialValues.put("heartrate", sleepHrVO.getHr());
            initialValues.put("recordtime", sleepHrVO.getRecordTime());
            re = database.insert("sleephr", null, initialValues);

        } catch (Exception exception) {
            re = -1;
            exception.printStackTrace();
        } finally {
            if (database != null) {
                database.close();
            }
        }
        return re;
    }

    public long addAcc(AccVO acc2vo) {
        if (acc2vo == null) {
            return -1;
        }
        long re;
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getWritableDatabase();
            ContentValues initialValues = new ContentValues();
            initialValues.put("maxacc", acc2vo.getMaxAcc());
            initialValues.put("avgacc", acc2vo.getAvgAcc());
            initialValues.put("recordtime", acc2vo.getRecordTime());
            re = database.insert("acc", null, initialValues);

        } catch (Exception exception) {
            re = -1;
            exception.printStackTrace();
        } finally {
            if (database != null) {
                database.close();
            }
        }
        return re;
    }
    public AvgHrVO getAvgHr(long rowid) {
       AvgHrVO vo = null;
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getReadableDatabase();
            String[] columns = new String[] { "heartrate", "recordtime" };
            String table = "avghr";
            String selection = "rowid=?";
            String[] selectArgs = new String[] {Long.toString(rowid) };
            Cursor cursor = database.query(table, columns, selection,
                    selectArgs, null, null, null);
            if (cursor != null) {
                if (cursor.moveToNext()) {
                    vo = new AvgHrVO();
                    vo.setHrValue(cursor.getInt(cursor
                            .getColumnIndex("heartrate")));
                    vo.setRecordTime(cursor.getLong(cursor
                            .getColumnIndex("recordtime")));
                }
                cursor.close();
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            if(database!=null)
            {
                database.close();
            }
        }
        return vo;
    }
    public AccVO getAcc(long rowid) {
        AccVO vo = null;
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getReadableDatabase();
            String[] columns = new String[] { "maxacc","avgacc", "recordtime" };
            String table = "acc";
            String selection = "rowid=?";
            String[] selectArgs = new String[] {Long.toString(rowid) };
            Cursor cursor = database.query(table, columns, selection,
                    selectArgs, null, null, null);
            if (cursor != null) {
                if (cursor.moveToNext()) {
                    vo = new AccVO();
                    vo.setMaxAcc(cursor.getInt(cursor
                            .getColumnIndex("maxacc")));
                    vo.setAvgAcc(cursor.getInt(cursor
                            .getColumnIndex("avgacc")));
                    vo.setRecordTime(cursor.getLong(cursor
                            .getColumnIndex("recordtime")));
                }
                cursor.close();
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            if(database!=null)
            {
                database.close();
            }
        }
        return vo;
    }
    public HrvVO getHrv(long rowid) {
        HrvVO vo = null;
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getReadableDatabase();
            String[] columns = new String[] { "score", "recordtime" };
            String table = "hrv";
            String selection = "rowid=?";
            String[] selectArgs = new String[] {Long.toString(rowid) };
            Cursor cursor = database.query(table, columns, selection,
                    selectArgs, null, null, null);
            if (cursor != null) {
                if (cursor.moveToNext()) {
                    vo = new HrvVO();
                    vo.setScore(cursor.getInt(cursor
                            .getColumnIndex("score")));
                    vo.setRecordTime(cursor.getLong(cursor
                            .getColumnIndex("recordtime")));
                }
                cursor.close();
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            if(database!=null)
            {
                database.close();
            }
        }
        return vo;
    }
    public SleepHrVO getSleepHr(long rowid) {
        SleepHrVO vo = null;
        SQLiteDatabase database = null;
        try {
            database = mDatabaseOpenHelper.getReadableDatabase();
            String[] columns = new String[] { "heartrate", "recordtime" };
            String table = "sleephr";
            String selection = "rowid=?";
            String[] selectArgs = new String[] {Long.toString(rowid) };
            Cursor cursor = database.query(table, columns, selection,
                    selectArgs, null, null, null);
            if (cursor != null) {
                if (cursor.moveToNext()) {
                    vo = new SleepHrVO();
                    vo.setHr(cursor.getInt(cursor
                            .getColumnIndex("heartrate")));
                    vo.setRecordTime(cursor.getLong(cursor
                            .getColumnIndex("recordtime")));
                }
                cursor.close();
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            if(database!=null)
            {
                database.close();
            }
        }
        return vo;
    }
    public static class HealthDbHelper extends BleSQLiteOpenHelper {

        public HealthDbHelper(Context context) {
            super(context, DATABASE_NAME, null, DATABASE_VERSION);
        }

        @Override
        public void onCreate(SQLiteDatabase db) {
            db.execSQL("create table heartrate(id INTEGER PRIMARY KEY AUTOINCREMENT,hrseq int,heartrate int,recordtime double)");
            db.execSQL("create table mzklog(id INTEGER PRIMARY KEY AUTOINCREMENT,loglevel varchar(20),logtext vachar(300),logtag vachar(300),logdate varchar(50))");
            db.execSQL("create table hrv(id INTEGER PRIMARY KEY AUTOINCREMENT,score int,arrhythmiaflag int,helathflag int,recordtime double,lostcount int)");
            db.execSQL("create table mzkhr(id INTEGER PRIMARY KEY AUTOINCREMENT,heartrate TINYINT,recordtime double,rr1 double,rr2 double)");
            db.execSQL("create table avghr(id INTEGER PRIMARY KEY AUTOINCREMENT,heartrate TINYINT,recordtime double)");
            db.execSQL("create table sleephr(id INTEGER PRIMARY KEY AUTOINCREMENT,heartrate TINYINT,recordtime double)");
            db.execSQL("create table acc(id INTEGER PRIMARY KEY AUTOINCREMENT,maxacc TINYINT,avgacc TINYINT,recordtime double)");
        }

        @Override
        public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
            db.execSQL("create table mzklog(id INTEGER PRIMARY KEY AUTOINCREMENT,loglevel varchar(20),logtext vachar(300),logtag vachar(300),logdate varchar(50))");
        }
    }

}
