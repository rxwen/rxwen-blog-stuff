/*
 * This file is auto-generated.  DO NOT MODIFY.
 * Original file: D:\\home\\documents\\rxwen-blog-stuff\\android\\rpc-with-service\\app1\\src\\com\\rmd\\ISvcController.aidl
 */
package com.rmd;
import java.lang.String;
import android.os.RemoteException;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Binder;
import android.os.Parcel;
public interface ISvcController extends android.os.IInterface
{
/** Local-side IPC implementation stub class. */
public static abstract class Stub extends android.os.Binder implements com.rmd.ISvcController
{
private static final java.lang.String DESCRIPTOR = "com.rmd.ISvcController";
/** Construct the stub at attach it to the interface. */
public Stub()
{
this.attachInterface(this, DESCRIPTOR);
}
/**
 * Cast an IBinder object into an ISvcController interface,
 * generating a proxy if needed.
 */
public static com.rmd.ISvcController asInterface(android.os.IBinder obj)
{
if ((obj==null)) {
return null;
}
android.os.IInterface iin = (android.os.IInterface)obj.queryLocalInterface(DESCRIPTOR);
if (((iin!=null)&&(iin instanceof com.rmd.ISvcController))) {
return ((com.rmd.ISvcController)iin);
}
return new com.rmd.ISvcController.Stub.Proxy(obj);
}
public android.os.IBinder asBinder()
{
return this;
}
public boolean onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int flags) throws android.os.RemoteException
{
switch (code)
{
case INTERFACE_TRANSACTION:
{
reply.writeString(DESCRIPTOR);
return true;
}
case TRANSACTION_anotherFunc:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
this.anotherFunc(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_foo:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
this.foo(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_bar:
{
data.enforceInterface(DESCRIPTOR);
java.lang.String _arg0;
_arg0 = data.readString();
this.bar(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_newFunc:
{
data.enforceInterface(DESCRIPTOR);
int _arg0;
_arg0 = data.readInt();
this.newFunc(_arg0);
reply.writeNoException();
return true;
}
case TRANSACTION_newFunc2:
{
data.enforceInterface(DESCRIPTOR);
int _arg0;
_arg0 = data.readInt();
this.newFunc2(_arg0);
reply.writeNoException();
return true;
}
}
return super.onTransact(code, data, reply, flags);
}
private static class Proxy implements com.rmd.ISvcController
{
private android.os.IBinder mRemote;
Proxy(android.os.IBinder remote)
{
mRemote = remote;
}
public android.os.IBinder asBinder()
{
return mRemote;
}
public java.lang.String getInterfaceDescriptor()
{
return DESCRIPTOR;
}
public void anotherFunc(java.lang.String arg) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(arg);
mRemote.transact(Stub.TRANSACTION_anotherFunc, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
public void foo(java.lang.String arg) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(arg);
mRemote.transact(Stub.TRANSACTION_foo, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
public void bar(java.lang.String arg) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeString(arg);
mRemote.transact(Stub.TRANSACTION_bar, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
public void newFunc(int arg) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeInt(arg);
mRemote.transact(Stub.TRANSACTION_newFunc, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
public void newFunc2(int arg) throws android.os.RemoteException
{
android.os.Parcel _data = android.os.Parcel.obtain();
android.os.Parcel _reply = android.os.Parcel.obtain();
try {
_data.writeInterfaceToken(DESCRIPTOR);
_data.writeInt(arg);
mRemote.transact(Stub.TRANSACTION_newFunc2, _data, _reply, 0);
_reply.readException();
}
finally {
_reply.recycle();
_data.recycle();
}
}
}
static final int TRANSACTION_anotherFunc = (IBinder.FIRST_CALL_TRANSACTION + 0);
static final int TRANSACTION_foo = (IBinder.FIRST_CALL_TRANSACTION + 1);
static final int TRANSACTION_bar = (IBinder.FIRST_CALL_TRANSACTION + 2);
static final int TRANSACTION_newFunc = (IBinder.FIRST_CALL_TRANSACTION + 3);
static final int TRANSACTION_newFunc2 = (IBinder.FIRST_CALL_TRANSACTION + 4);
}
public void anotherFunc(java.lang.String arg) throws android.os.RemoteException;
public void foo(java.lang.String arg) throws android.os.RemoteException;
public void bar(java.lang.String arg) throws android.os.RemoteException;
public void newFunc(int arg) throws android.os.RemoteException;
public void newFunc2(int arg) throws android.os.RemoteException;
}
