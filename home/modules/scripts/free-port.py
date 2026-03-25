#!/usr/bin/env python3
#
import socket
with socket.socket() as s:
    s.bind(("", 0))
    print(s.getsockname()[1])
