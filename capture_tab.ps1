# Bring a specific Chrome TAB to the foreground (by page-title substring) and
# capture it to PNG. The Claude extension drives tabs via CDP without making
# them the active/visible tab, so a plain window-grab catches the wrong tab.
# This walks every Chrome window, Ctrl+Tab-cycles through its tabs until the
# foreground window title matches, then screenshots that window.

param(
    [Parameter(Mandatory = $true)][string]$TitleMatch,
    [Parameter(Mandatory = $true)][string]$OutPath,
    [int]$MaxTabs = 30
)

Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

public static class Tabs {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr lParam);
    [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern int GetWindowTextLength(IntPtr h);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();

    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }

    // every top-level window whose title contains "Google Chrome"
    public static List<IntPtr> ChromeWindows() {
        var hits = new List<IntPtr>();
        EnumWindows((h, l) => {
            int len = GetWindowTextLength(h);
            if (len == 0) return true;
            var sb = new StringBuilder(len + 1);
            GetWindowText(h, sb, sb.Capacity);
            if (sb.ToString().IndexOf("Google Chrome", StringComparison.OrdinalIgnoreCase) >= 0)
                hits.Add(h);
            return true;
        }, IntPtr.Zero);
        return hits;
    }

    public static string Title(IntPtr h) {
        int len = GetWindowTextLength(h);
        var sb = new StringBuilder(len + 1);
        GetWindowText(h, sb, sb.Capacity);
        return sb.ToString();
    }
}
"@

$ws = New-Object -ComObject WScript.Shell

function Capture-Window([IntPtr]$hWnd, [string]$path) {
    $r = New-Object Tabs+RECT
    [Tabs]::GetWindowRect($hWnd, [ref]$r) | Out-Null
    $w = $r.Right - $r.Left; $h = $r.Bottom - $r.Top
    if ($w -le 0 -or $h -le 0) { return $false }
    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen([System.Drawing.Point]::new($r.Left, $r.Top), [System.Drawing.Point]::Empty, [System.Drawing.Size]::new($w, $h))
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    return $true
}

$windows = [Tabs]::ChromeWindows()
if ($windows.Count -eq 0) { Write-Error "No Chrome windows found."; exit 1 }

foreach ($hWnd in $windows) {
    [Tabs]::ShowWindow($hWnd, 9) | Out-Null   # SW_RESTORE
    [Tabs]::SetForegroundWindow($hWnd) | Out-Null
    Start-Sleep -Milliseconds 500
    for ($i = 0; $i -lt $MaxTabs; $i++) {
        $fg = [Tabs]::GetForegroundWindow()
        $t = [Tabs]::Title($fg)
        if ($t.IndexOf($TitleMatch, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            Start-Sleep -Milliseconds 500
            if (Capture-Window $fg $OutPath) {
                $r = New-Object Tabs+RECT; [Tabs]::GetWindowRect($fg, [ref]$r) | Out-Null
                Write-Output ("MATCH '{0}' -> {1}x{2} -> {3}" -f $t, ($r.Right-$r.Left), ($r.Bottom-$r.Top), $OutPath)
                exit 0
            }
        }
        $ws.SendKeys("^{TAB}")          # next tab in this window
        Start-Sleep -Milliseconds 250
    }
}

Write-Error "No tab matching '$TitleMatch' found after cycling tabs in $($windows.Count) Chrome window(s)."
exit 1
