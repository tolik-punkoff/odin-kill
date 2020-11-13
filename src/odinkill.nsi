Unicode true

!include gvv.nsi
!include Logiclib.nsh
!include x64.nsh

!define APPNAME "OdinKill"
!define APPNAMEANDVERSION "OdinKill 0.1"

; Main Install settings
Name "${APPNAMEANDVERSION}"
InstallDir "$TEMP\OdinKill"
OutFile "odinkill-binary\OdinKill.exe"

ShowInstDetails show

Section
	
	SetOverwrite on
	
	;detect after reboot Odin kill stage
	ReadRegStr $R0 HKCU "Software\Microsoft\Windows\CurrentVersion\" "${APPNAME}_afterreboot"
	StrCmp "$R0" "1" AfterReboot
	
	${GetWindowsVersion} $R0 ;Check Win7
	StrCmp "$R0" "7" 0 NoWin7
	MessageBox MB_OKCANCEL|MB_ICONQUESTION "Remove Odin (Windows 7 crack/activator)? $\n System will be reboot automatically." IDYES 0 IDCANCEL EndSection
	DetailPrint "Checking Odin registry key..."
	${If} ${IsNativeAMD64} ;x64 OS
		ClearErrors
		EnumRegKey $0 HKLM "SYSTEM\CurrentControlSet\services\oem-drv64" 0
		${If} ${Errors}
			DetailPrint "x64 Odin driver registry key not detected!"
			MessageBox MB_OKCANCEL|MB_ICONQUESTION "Odin driver registry key not detected (maybe Odin not installed). Continue?" IDYES 0 IDCANCEL EndSection
		${Else}
			DetailPrint "OK"
		${EndIf}		
	${ElseIf} ${IsNativeIA32} ;x86 OS
		ClearErrors
		EnumRegKey $0 HKLM "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\oem-drv86" 0
		${If} ${Errors}
			DetailPrint "x86 Odin driver registry key not detected!"
			MessageBox MB_OKCANCEL|MB_ICONQUESTION "Odin driver registry key not detected (maybe Odin not installed). Continue?" IDYES 0 IDCANCEL EndSection
		${Else}	
			DetailPrint "OK"
		${EndIf}		
	${Else} ; unsupported architecture
    DetailPrint "Unsupported CPU architecture!"
		MessageBox MB_OK|MB_ICONSTOP "Unsupported CPU architecture!"
		Goto EndSection
  ${EndIf}
	
	;Removing Odin stage 1
	
	SetOutPath "$INSTDIR"
	File "bin\SetACL.exe"
	
	;Create Restore Point
	DetailPrint "Create restore point..."
	SysRestore::StartRestorePoint "OdinRemove RestorePoint"
	Pop $0
	${If} $0 = 0
		DetailPrint "OK"
	${ElseIf} $0 = 1
		DetailPrint "Start point already set (start function only)."
	${ElseIf} $0 = 10
		DetailPrint "The system is running in safe mode. "
	${ElseIf} $0 = 13
		DetailPrint "The sequence number is invalid."
	${ElseIf} $0 = 80
		DetailPrint "Windows Me: Pending file-rename operations exist in the file %windir%\Wininit.ini."
	${ElseIf} $0 = 112
		DetailPrint "System Restore is in standby mode because disk space is low."
	${ElseIf} $0 = 1058
		DetailPrint "System Restore is disabled."
	${ElseIf} $0 = 1359
		DetailPrint "An internal error with system restore occurred."
	${ElseIf} $0 = 1460
		DetailPrint "The call timed out due to a wait on a mutex for setting restore points."
	${Else}
		DetailPrint "Unknow error."
	${EndIf}
	
	;Set access right for registry keys
	DetailPrint "Set access right for registry keys..."
	ExecWait '$INSTDIR\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn list -lst "f:sddl;w:d,s,o" -bckp "$INSTDIR\regrights.bkp"' $0
	DetailPrint "Return code: $0"
	ExecWait '$INSTDIR\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn setowner -ownr "n:%USERDOMAIN%\%USERNAME%"' $0
	DetailPrint "Return code: $0"
	ExecWait '$INSTDIR\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn ace -ace " "n:%USERDOMAIN%\%USERNAME%;p:full"' $0
	DetailPrint "Return code: $0"
	
	${If} ${IsNativeAMD64} ;x64 OS
		DetailPrint "System architecture is x64"
		DetailPrint "Restore boot configuration..."
		ExecWait "$SYSDIR\BCDEDIT.exe /set {current} path \Windows\System32\winload.exe" $0
		DetailPrint "Return code: $0"
		ExecWait "$SYSDIR\BCDEDIT.exe /deletevalue {current} kernel" $0
		DetailPrint "Return code: $0"
		ExecWait "$SYSDIR\BCDEDIT.exe /deletevalue {current} nointegritychecks" $0
		DetailPrint "Return code: $0"
		ExecWait "$SYSDIR\BCDEDIT.exe /deletevalue {current} custom:26000027" $0
		DetailPrint "Return code: $0"
		
		DetailPrint "Remove registry keys..."
		DeleteRegKey HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\services\oem-drv64"
		DeleteRegKey HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Enum\Root\LEGACY_OEM-DRV64"
	${ElseIf} ${IsNativeIA32} ;x86 OS
		DetailPrint "System architecture is x86"
		DetailPrint "Remove registry keys..."
		DeleteRegKey HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\services\oem-drv86"
		DeleteRegKey HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Enum\Root\LEGACY_OEM-DRV86"
	${Else} ;unsupported architecture
		Goto EndSection
	${EndIf}
	
	DetailPrint "Restore access right for registry keys..."
	ExecWait '$INSTDIR\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn restore -bckp "$INSTDIR\regrights.bkp"'
	DetailPrint "Return code: $0"
	
	;Prepare continue after restart
	WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\RunOnce" "${APPNAME}" "$EXEPATH"
	WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\" "${APPNAME}_afterreboot" "1"
	
	;Finish restore point
	SysRestore::FinishRestorePoint
	DetailPrint "Finish restore point..."
	${If} $0 = 0
		DetailPrint "OK"
	${ElseIf} $0 = 2
		DetailPrint "No Start point set (finish function only)."
	${Else}
		DetailPrint "Unknow error."
	${EndIf}
		
	Reboot
	Goto EndSection
	
	AfterReboot:
		DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\" "${APPNAME}_afterreboot"
		DetailPrint "Continue after reboot..."
		DetailPrint "Remove files..."
		Delete "$WINDIR\system32\drivers\oem-drv64.sys"
		Delete "$WINDIR\system32\xNtKrnl.exe"
		Delete "$WINDIR\system32\xOsLoad.exe"
		Delete "$WINDIR\System32\ru-RU\xOsLoad.exe.mui"
		Delete "$WINDIR\System32\en-US\xOsLoad.exe.mui"
		Delete "$WINDIR\system32\drivers\oem-drv86.sys"

		Goto EndSection
		
	NoWin7:
		DetailPrint "OS is not Windows 7. Exitting..."
		MessageBox MB_OK|MB_ICONSTOP "OS is not Windows 7!"
		
	EndSection:
SectionEnd
; eof