# sms-convert
Convert SMS from Android to Windows Phone

andriod-to-windows-sms.pl provides the ability to convert SMS exported from Android phones by [Wondershare MobileGo] (http://www.wondershare.net/mobilego/?icn=nav) to Windows Phone format used by [Transfer My Data] (https://www.microsoft.com/en-us/store/apps/transfer-my-data/9wzdncrfj3dr).

To use it simply

1. Export your SMS from your Android phone using Wondershare MobileGo, which will create an SMS.xml file.
2. cat SMS.xml | ./andriod-to-windows-sms.pl > sms.vmsg
3. Copy sms.vmsg to your SD card.
4. Run Transfer My Data
5. Swipe up from the ... to expose the Import / Export options
6. Select Import from SD Card
7. Select SMS
