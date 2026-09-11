@echo off
rem ----------------------------------------------------------------
rem Config: Windows CMD Profile
rem ----------------------------------------------------------------

rem ================================
rem SETUP
rem ================================
chcp 65001 > nul
%USERPROFILE%\.vault\vault.cmd

rem ================================
rem VARS
rem ================================
set "HOME=%USERPROFILE%"
set "SYSTEM32=C:\Windows\System32"
set "ONEDRIVE=%HOME%\OneDrive"
set "DESKTOP=%ONEDRIVE%\Área de Trabalho"
set "DOCUMENTS=%ONEDRIVE%\Documentos"
set "IMAGES=%ONEDRIVE%\Imagens"
set "WORKSPACE=%ONEDRIVE%\Workspace"
set "DOWNLOADS=%HOME%\Downloads"
set "CLINKPATH=%PROGRAMFILES(x86)%\clink"
set "CMD_PROFILE=%HOME%\profile.cmd"
set "LUA_PROFILE=%CLINKPATH%\profile.lua"
set "PWSH_PROFILE=C:\Program Files\PowerShell\7\profile.ps1"
set "VIRTUAL_STORE=%LOCALAPPDATA%\VirtualStore"
set "FASM_STORE=%VIRTUAL_STORE%\Program Files\FASM"
set "FASM2_STORE=%VIRTUAL_STORE%\Program Files\FASM2"
set "FASMG_STORE=%VIRTUAL_STORE%\Program Files\FASMG"
set "FASMARM_STORE=%VIRTUAL_STORE%\Program Files\FASMARM"

rem ================================
rem APPEARANCE
rem ================================
rem oh-my-posh init cmd --config "%HOME%\.oh-my-posh\themes\pure.omp.json" > "%HOME%\.oh-my-posh.lua"
rem oh-my-posh init cmd --config "%HOME%\.oh-my-posh\themes\pure.omp.json" > "%CLINKPATH%\profile.lua"
rem oh-my-posh init cmd --config "%HOME%\.oh-my-posh\themes\atomic.omp.json" > "%HOME%\.oh-my-posh.lua"
rem oh-my-posh init cmd --config "%HOME%\.oh-my-posh\themes\atomic.omp.json" > "%CLINKPATH%\profile.lua"
