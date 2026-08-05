@echo off
rem ==================================================================
rem =Set all EXPRESSCLUSTER services from Manual to Automatic-startup=
rem ==================================================================

call clpsvcctrl.bat --enable -a
