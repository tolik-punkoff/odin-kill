@ rem echo Этот файл должен быть запущен с правами администратора и после выполнения Deactivator'а
@ rem echo Чтобы окончательно удалить следы активатора нажмите любую клавишу, иначе CTRL+C!
@ rem pause


DEL "%windir%\system32\drivers\oem-drv64.sys"
DEL "%windir%\system32\xNtKrnl.exe"
DEL "%windir%\system32\xOsLoad.exe"
DEL "%windir%\System32\ru-RU\xOsLoad.exe.mui"
DEL "%windir%\System32\en-US\xOsLoad.exe.mui"
DEL "%windir%\system32\drivers\oem-drv86.sys"

@echo "Clean complete."
@pause