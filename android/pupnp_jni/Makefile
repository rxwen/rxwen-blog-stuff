all: jni java

.PHONY: jni install clean java

jni:
	ndk-build -C jni V=1

java:
	ant clean
	ant debug

install:
	adb uninstall com.rmd.tpupnp
	ant debug install

clean:
	adb uninstall com.rmd.tpupnp
	ndk-build -C jni clean
	ant clean
