@echo off
rem ==================================================================
rem =Set all EXPRESSCLUSTER services from Automatic to Manual startup=
rem ==================================================================

call clpsvcctrl.bat --disable -a
