<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1291603478045" ID="ID_347589890" MODIFIED="1291604791959" TEXT="GStreamer">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291603864410" ID="ID_1309676795" MODIFIED="1291604791959" POSITION="left" TEXT="key concepts">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291603881927" ID="ID_1805258664" MODIFIED="1291604808478" TEXT="element">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604365799" ID="ID_1526522683" MODIFIED="1291604791957" TEXT="type">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604376455" ID="ID_866501519" MODIFIED="1291604791957" TEXT="source element">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604380943" ID="ID_248568395" MODIFIED="1291604791957" TEXT="filter, convertor, demuxer, muxer, codec">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604414807" ID="ID_743973160" MODIFIED="1291604791956" TEXT="sink element">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
</node>
<node CREATED="1291603872671" ID="ID_935700913" MODIFIED="1291604791959" TEXT="bin">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604653383" ID="ID_62378932" MODIFIED="1291604791959" TEXT="special element">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604623191" ID="ID_1971707445" MODIFIED="1291604791958" TEXT="composition pattern">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
<node CREATED="1291603885375" ID="ID_830719102" MODIFIED="1291604791958" TEXT="pipeline">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604433239" ID="ID_676741103" MODIFIED="1291604791958" TEXT="special toplevel bin">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
<node CREATED="1291603890463" ID="ID_502480541" MODIFIED="1291604791956" TEXT="pad">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604072879" ID="ID_1697365596" MODIFIED="1291604791956" TEXT="direction">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291603904999" ID="ID_1607059904" MODIFIED="1291604791955" TEXT="sink pad">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291603896583" ID="ID_842407852" MODIFIED="1291604791955" TEXT="source pad">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
<node CREATED="1291604698039" ID="ID_604315726" MODIFIED="1291604791955" TEXT="availability">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604716263" ID="ID_1005762471" MODIFIED="1291604791954" TEXT="always">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604737407" ID="ID_1827471544" MODIFIED="1291604791954" TEXT="sometimes">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604743543" ID="ID_430676933" MODIFIED="1291604791953" TEXT="on request">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
<node CREATED="1291700058703" ID="ID_1447432275" MODIFIED="1291700061682" TEXT="capability">
<node CREATED="1291700125711" ID="ID_1177200044" MODIFIED="1291700142418" TEXT="described in GstCaps object">
<node CREATED="1291700155431" ID="ID_692624038" MODIFIED="1291700168330" TEXT="contain one or more GstStructure"/>
</node>
<node CREATED="1291700185039" ID="ID_572448988" MODIFIED="1291700198258" TEXT="can be attached to pad template or pad"/>
<node CREATED="1291700311351" ID="ID_240170332" MODIFIED="1291700323307" TEXT="describe media type of pad"/>
</node>
<node CREATED="1291699954711" ID="ID_599288202" MODIFIED="1291699957194" TEXT="ghost pad">
<node CREATED="1291699959071" ID="ID_1426778461" MODIFIED="1291699991170" TEXT="a fake pad on bin"/>
<node CREATED="1291699993103" ID="ID_1067902167" MODIFIED="1291700018562" TEXT="actually connect to a real pad on a element within the bin"/>
<node CREATED="1291700026095" ID="ID_1076397685" MODIFIED="1291700045522" TEXT="bin can be used as normal element"/>
</node>
</node>
<node CREATED="1291603911335" ID="ID_426497663" MODIFIED="1291604791953" TEXT="bus">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604532839" ID="ID_121227000" MODIFIED="1291604791953" TEXT="app can be thread agnostic">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604568327" ID="ID_414932625" MODIFIED="1291604791952" TEXT="usage">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604572807" ID="ID_419658407" MODIFIED="1291604791952" TEXT="gst_bus_add_watch">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604583231" ID="ID_277090641" MODIFIED="1291604791952" TEXT="gst_bus_add_signal_watch">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604596631" ID="ID_205061867" MODIFIED="1291604791951" TEXT="gst_bus_peek">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604602591" ID="ID_1687728698" MODIFIED="1291604791951" TEXT="gst_bus_poll">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
</node>
<node CREATED="1291603913559" ID="ID_29328040" MODIFIED="1291604791950" TEXT="message">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291699931327" ID="ID_244655087" MODIFIED="1291699941627" TEXT="passed alone bus"/>
</node>
<node CREATED="1291699925911" ID="ID_1852080534" MODIFIED="1291699927570" TEXT="buffer">
<node CREATED="1291700508159" ID="ID_664085109" MODIFIED="1291700511658" TEXT="actual media data"/>
</node>
<node CREATED="1291699919266" ID="ID_1468526890" MODIFIED="1291699921706" TEXT="event">
<node CREATED="1291700514951" ID="ID_1647870688" MODIFIED="1291700519602" TEXT="control information"/>
</node>
</node>
<node CREATED="1291604034466" ID="ID_462547406" MODIFIED="1291604791950" POSITION="right" TEXT="tools">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
<node CREATED="1291604037391" ID="ID_1951762524" MODIFIED="1291604791950" TEXT="gst-inspect">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604044031" ID="ID_1908354064" MODIFIED="1291604791949" TEXT="gst-launch">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
<node CREATED="1291604048263" ID="ID_1826112715" MODIFIED="1291604791949" TEXT="gst-editor">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
<node CREATED="1291604330263" ID="ID_583252003" MODIFIED="1291604791948" POSITION="right" TEXT="gobject">
<font NAME="WenQuanYi Micro Hei" SIZE="12"/>
</node>
</node>
</map>
