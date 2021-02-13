@echo off
rem ============================================================
rem =Set server SAN policy to automatically mount new disks.   =
rem =The mirror disk should automatically mount on the Azure VM=
rem ============================================================

echo san policy=onlineall | diskpart
