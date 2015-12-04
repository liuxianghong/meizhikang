//
// Created by numb on 2015/11/24.
//
#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<pthread.h>
#include<android/log.h>
#include <linux/netlink.h>
#include <linux/socket.h>
#include <linux/netlink.h>
#include <sys/socket.h>
#include "com_gmk_wear_test_service_HealthDataConfig.h"
#define TAG "DATA_JNI"
#define MAX_PAYLOAD 1024 /* maximum payload size*/
struct sockaddr_nl src_addr, dest_addr;
struct nlmsghdr *nlh = NULL;
struct iovec iov;
int sock_fd;
struct msghdr msg;
//全局变量
JavaVM *g_jvm = NULL;
jobject callback = NULL;
int sendType = 0;
jint linkStatus=0;
void *thread_fun(void* arg)
{
    JNIEnv *env;
    jclass cls;
    jmethodID mid;
   // env= g_jvm->
    //Attach主线程
   if(g_jvm->AttachCurrentThread( &env, NULL) != JNI_OK)
    {
        return NULL;
    }
    sock_fd = socket(AF_NETLINK, SOCK_RAW, 30);
    if(sock_fd==-1)
    {
        linkStatus=-1;
    }
    __android_log_print(ANDROID_LOG_INFO,
                        "data jni",
                        "sock_fd=%d,and err=%d\n",sock_fd,errno);
    memset(&src_addr, 0, sizeof(src_addr));
    src_addr.nl_family = AF_NETLINK;
    src_addr.nl_pid = getpid(); /* self pid */
    src_addr.nl_groups = 0; /* not in mcast groups */
  int bindnum=  bind(sock_fd, (struct sockaddr*) &src_addr, sizeof(src_addr));
    __android_log_print(ANDROID_LOG_INFO,
                        "data jni",
                        "bind+ num=%d\n",bindnum);
    if(bindnum==-1)
    {
        linkStatus=-1;
    }
    struct timeval timeout;
    timeout.tv_sec=2;
    timeout.tv_usec=500;
    int result = setsockopt(sock_fd,SOL_SOCKET,SO_RCVTIMEO,(char *)&timeout.tv_sec,sizeof(struct timeval));
    if (result < 0)
    {
        __android_log_print(ANDROID_LOG_INFO,
                            "data jni",
                            "SO_RCVTIMEO error");

    }
    char param[5];
    param[0]='g';
    param[1]='m';
    param[2]='k';
    param[3]=0x00;
    param[4]=0x01;
    linkStatus=1;
    memset(&iov, 0, sizeof(iov));
    memset(&msg, 0, sizeof(msg));
    memset(&dest_addr, 0, sizeof(dest_addr));
    dest_addr.nl_family = AF_NETLINK;
    dest_addr.nl_pid = 0; /* For Linux Kernel */
    dest_addr.nl_groups = 0; /* unicast */
    nlh = (struct nlmsghdr *) malloc(NLMSG_SPACE(MAX_PAYLOAD));
    /* Fill the netlink message header */
    nlh->nlmsg_len = NLMSG_SPACE(MAX_PAYLOAD);
    nlh->nlmsg_pid = getpid(); /* self pid */
    nlh->nlmsg_flags = 0;
    /* Fill in the netlink message payload */
    memcpy( NLMSG_DATA(nlh), param,5);
    iov.iov_base = (void *) nlh;
    iov.iov_len = nlh->nlmsg_len;
    msg.msg_name = (void *) &dest_addr;
    msg.msg_namelen = sizeof(dest_addr);
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;
    __android_log_print(ANDROID_LOG_INFO,
                        "data jni",
                        "prev send");
   int sendnum= sendmsg(sock_fd, &msg, 0);
    linkStatus=1;
    __android_log_print(ANDROID_LOG_INFO,
                        "data jni",
                        "sended+ num=%d\n",sendnum);
    /* Read message from kernel */
    memset(nlh, 0, NLMSG_SPACE(MAX_PAYLOAD));
   // recvmsg(sock_fd, &msg, 0);
    while(true)
    {
        if(sendType!=0)
        {
            param[0]='g';
            param[1]='m';
            param[2]='k';
            param[3]=0x00;
            param[4]=sendType==2?0x00:0x01;
            linkStatus==sendType==2?0:1;
            memcpy(NLMSG_DATA(nlh), param,5);
            int sendnum= sendmsg(sock_fd, &msg, 0);
            sendType=0;
            __android_log_print(ANDROID_LOG_INFO,
                                "data jni",
                                "sended+ num=%d\n",sendnum);
        }
        __android_log_print(ANDROID_LOG_INFO,
                            "data jni",
                            "rev recv");


      int length=  recvmsg(sock_fd, &msg, 0);
        if(length==-1)
        {
            __android_log_print(ANDROID_LOG_INFO,
                                "data jni",
                                " error %d \n",errno);
            continue;
           // pthread_exit(0);

        }
        __android_log_print(ANDROID_LOG_INFO,
                            "data jni",
                            " recved");
        char * msgdata=(char *)NLMSG_DATA(nlh);
        __android_log_print(ANDROID_LOG_INFO,
                            "data jni",
                            " recved2 %s\n",msgdata);
        if (strncmp(msgdata, "GMK", strlen("GMK")))
        {
            __android_log_print(ANDROID_LOG_INFO,
                                "data jni",
                                " recved3");
            cls = env->GetObjectClass(callback);
            __android_log_print(ANDROID_LOG_INFO,
                                "data jni",
                                " recved4");
            if(cls == NULL)
            {
                goto error;
            }
            int arg1=0;
           switch (msgdata[3])
           {
               case 0:
                   mid = env->GetMethodID( cls, "onOk", "(I)V");
                   env->CallVoidMethod(callback,mid,0x00);
                   break;
               case 1:
                   mid = env->GetMethodID( cls, "onHr", "(I)V");
                   env->CallVoidMethod(callback,mid,arg1&msgdata[4]);
                   break;
               case 2:
                   mid = env->GetMethodID( cls, "onHrv", "(II)V");
                   env->CallVoidMethod(callback,mid,arg1&msgdata[4],arg1&msgdata[5]);
                   break;
               case 3:
                   mid = env->GetMethodID( cls, "onAvgHr", "(II)V");
                   env->CallVoidMethod(callback,mid,arg1&msgdata[4],arg1&msgdata[5]);
                   break;
               case 4:
                   mid = env->GetMethodID( cls, "onAcc", "(I)V");
                   env->CallVoidMethod(callback,mid,arg1&msgdata[4]);
                   break;
               case 5:
                   mid = env->GetMethodID( cls, "onSleepHr", "(I)V");
                   env->CallVoidMethod(callback,mid,arg1&msgdata[4]);
                   break;
           }
        }
    }
    error:
    //Detach主线程
    if(g_jvm->DetachCurrentThread() != JNI_OK)
    {
   }


    pthread_exit(0);
}


/*
 * Class:     com_gmk_wear_test_service_HealthDataConfig
 * Method:    setDataCallback
 * Signature: (Lcom/gmk/wear/test/service/HealthDataCallback;)V
 */
JNIEXPORT void JNICALL Java_com_gmk_wear_test_service_HealthDataConfig_setDataCallback
        (JNIEnv * env, jobject , jobject refobj)
{
    callback = env->NewGlobalRef(refobj);
}

/*
 * Class:     com_gmk_wear_test_service_HealthDataConfig
 * Method:    init
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_gmk_wear_test_service_HealthDataConfig_init
        (JNIEnv *env, jobject)
{
    jboolean  re=false;
    env->GetJavaVM(&g_jvm);
    int i=0;
    pthread_t pt;
    pthread_create(&pt, NULL, &thread_fun, (void *)i);
    return re;
}

/*
 * Class:     com_gmk_wear_test_service_HealthDataConfig
 * Method:    close
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_gmk_wear_test_service_HealthDataConfig_close
        (JNIEnv * env, jobject)
{
    sendType=2;
    return true;
}

JNIEXPORT jboolean JNICALL Java_com_gmk_wear_test_service_HealthDataConfig_openSensor
        (JNIEnv *, jobject)
{
    sendType=1;
    return false;
}

/*
 * Class:     com_gmk_wear_test_service_HealthDataConfig
 * Method:    jniExit
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_gmk_wear_test_service_HealthDataConfig_jniExit
        (JNIEnv * env, jobject)
{
    jboolean  re=false;
    g_jvm=NULL;
    env->DeleteGlobalRef(callback);
    return re;
}



/*
 * Class:     com_gmk_wear_test_service_HealthDataConfig
 * Method:    checkLinkStatus
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_gmk_wear_test_service_HealthDataConfig_checkLinkStatus
        (JNIEnv *, jobject)
{
    return linkStatus;
}

