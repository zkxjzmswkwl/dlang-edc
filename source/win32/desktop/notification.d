import core.sys.windows.windows;
import core.stdc.string;
import std.string;
import std.conv;
import std.stdio;
import std.utf;

void win32ComNotification(string title, string content)
{
    enum NOTIFYICON_VERSION = 4;

    NOTIFYICONDATA nid;
    nid.cbSize = NOTIFYICONDATA.sizeof;
    nid.hWnd = GetConsoleWindow();
    nid.uID = 1;
    nid.uFlags = NIF_INFO | NIF_MESSAGE | NIF_ICON;
    nid.uCallbackMessage = WM_USER + 1;
    nid.hIcon = LoadIconA(cast(void*) 0, cast(char*) IDI_INFORMATION);
    nid.dwInfoFlags = NIIF_INFO;

    auto wideTitle = title.toUTF16();
    auto wideContent = content.toUTF16();

    wideTitle ~= 0;
    wideContent ~= 0;

    size_t titleLen = wideTitle.length > nid.szInfoTitle.length
        ? nid.szInfoTitle.length - 1 : wideTitle.length;
    size_t contentLen = wideContent.length > nid.szInfo.length
        ? nid.szInfo.length - 1 : wideContent.length;

    memcpy(nid.szInfoTitle.ptr, wideTitle.ptr, titleLen * wchar.sizeof);
    nid.szInfoTitle[titleLen] = 0;
    memcpy(nid.szInfo.ptr, wideContent.ptr, contentLen * wchar.sizeof);
    nid.szInfo[contentLen] = 0;
}