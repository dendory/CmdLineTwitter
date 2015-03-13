CmdLineTwitter
==============

Simple unofficial command line Twitter app for Windows.

This is a pretty simple Twitter command line client I made in Perl. It gives basic functions such as posting, searching, viewing timeline, adding and removing users. Logging in is done with a PIN code and tokens saved to the registry. You will need to create your own Twitter app on their dev site and input the proper app key and secrets. You can download a compiled binary for Windows at my site: http://dendory.net/?d=54239983

Feel free to use this code for your own projects...

Usage
-----
-  twitter -t|-timeline [count]
-  twitter -p|-post <text>
-  twitter -i|-inbox [count]
-  twitter -m|-message <user> <text>
-  twitter -f|-follow <user>
-  twitter -u|-unfollow <user>
-  twitter -e|-user <user>
-  twitter -s|-search <text>
-  twitter -r|-recent <text>
-  twitter -x|-retweets [count]
-  twitter -z|-mentions [count]
-  twitter -lang <language>
-  twitter -debug
-  twitter -login
-  twitter -logout
