@echo off
rem ========================================================
rem =Turn network discovery and file and printer sharing on=
rem =for all profiles (Private, Guest or Public, Domain)   =
rem ========================================================

rem Network Discovery:
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

rem File and Printer Sharing:
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
