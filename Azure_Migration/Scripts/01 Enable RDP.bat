@echo off
rem ==========================================================
rem =Enable RDP and allow remote desktop through the firewall=
rem ==========================================================

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes