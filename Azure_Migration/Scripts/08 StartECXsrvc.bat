@echo off
rem ===================================
rem =Start all EXPRESSCLUSTER services=
rem ===================================

net start "EXPRESSCLUSTER Event"
net start "EXPRESSCLUSTER"
net start "EXPRESSCLUSTER API"
net start "EXPRESSCLUSTER Information Base"
net start "EXPRESSCLUSTER Manager"
net start "EXPRESSCLUSTER Old API Support"
net start "EXPRESSCLUSTER Server"
net start "EXPRESSCLUSTER Transaction"
net start "EXPRESSCLUSTER Web Alert"