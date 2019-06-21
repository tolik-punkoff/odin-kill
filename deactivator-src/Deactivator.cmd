
@rem echo Этот файл должен быть запущен с правами администратора!
@rem pause
@rem echo Чтобы отключить активацию нажмите любую клавишу, иначе CTRL+C!
@rem pause

data\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn list -lst "f:sddl;w:d,s,o" -bckp "data\regrights.bkp"
data\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn setowner -ownr "n:%USERDOMAIN%\%USERNAME%"
data\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn ace -ace " "n:%USERDOMAIN%\%USERNAME%;p:full"


IF %PROCESSOR_ARCHITECTURE% == AMD64 (
	
	BCDEDIT /set {current} path \Windows\System32\winload.exe
	BCDEDIT /deletevalue {current} kernel
	BCDEDIT /deletevalue {current} nointegritychecks
	BCDEDIT /deletevalue {current} custom:26000027

		
	REGEDIT /s "data\anti-oem-drv64.reg"
) ELSE (
	
	REGEDIT /s "data\anti-oem-drv86.reg"
)

data\setacl.exe -on HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\Root -ot reg -actn restore -bckp "data\regrights.bkp"

data\sleep 7

SHUTDOWN /r /t 50

rem pause