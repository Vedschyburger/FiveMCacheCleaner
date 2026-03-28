<#
.SYNOPSIS
    FiveM Cache Cleaner (Neon Edition)
    
.DESCRIPTION
    Bereinigt FiveM-Caches mit modernem Neon-UI.
    Design: Rounded Corners, Neon Pink & Cyber Blue.
    
.AUTHOR
    Vedschyburger
#>

$ErrorActionPreference = "SilentlyContinue"

if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    Start-Process "powershell.exe" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-STA", "-File", "`"$PSCommandPath`"") | Out-Null
    return
}

try {
    Add-Type -AssemblyName PresentationFramework

    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="FiveM System Tool" Height="400" Width="640"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Topmost="True" WindowStyle="None" AllowsTransparency="True" Background="Transparent">
    
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="15">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border Background="#0D0D0D" CornerRadius="25" BorderBrush="#FF00FF" BorderThickness="2">
        <Grid Margin="25">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <StackPanel Grid.Row="0" Margin="0,0,0,20" HorizontalAlignment="Center">
                <TextBlock Name="HeaderTxt" Text="★ SYSTEM OVERRIDE ★" FontSize="28" FontWeight="ExtraBold" Foreground="#00FFFF" FontFamily="Segoe UI Semibold" TextAlignment="Center">
                    <TextBlock.Effect>
                        <DropShadowEffect Color="#00FFFF" BlurRadius="10" ShadowDepth="0"/>
                    </TextBlock.Effect>
                </TextBlock>
                <Border Height="2" Background="#FF00FF" Width="200" Margin="0,8,0,0">
                    <Border.Effect>
                        <DropShadowEffect Color="#FF00FF" BlurRadius="8" ShadowDepth="0"/>
                    </Border.Effect>
                </Border>
            </StackPanel>

            <Border Grid.Row="1" Background="#151515" CornerRadius="15" Padding="20">
                <StackPanel>
                    <TextBlock Name="WarningTitleTxt" Text="⚠️ DATA PURGE INITIALIZED" FontSize="16" FontWeight="Bold" Foreground="#FF00FF" Margin="0,0,0,10"/>
                    <TextBlock Name="WarningBodyTxt" Foreground="#FFFFFF" FontSize="14" TextWrapping="Wrap" LineHeight="22">
                        System cache detected as fragmented. Initializing protocol to wipe 'cache', 'server-cache' and 'priv' directories. FiveM will reboot post-execution.
                    </TextBlock>
                </StackPanel>
            </Border>

            <Grid Grid.Row="2" Margin="0,20,0,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Button Name="LangBtn" Grid.Column="0" Width="110" Height="40" Background="#1A1A1A" Foreground="#00FFFF" BorderBrush="#00FFFF" BorderThickness="1" FontSize="12" Cursor="Hand" Content="🌐 DEUTSCH"/>

                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button Name="CancelBtn" Width="110" Height="40" Background="Transparent" Foreground="#666666" BorderThickness="0" FontSize="13" FontWeight="Bold" Cursor="Hand" Content="ABORT"/>
                    <Button Name="OkBtn" Width="200" Height="40" Margin="15,0,0,0" Background="#FF00FF" Foreground="#FFFFFF" BorderThickness="0" FontSize="14" FontWeight="Black" Cursor="Hand" Content="EXECUTE CLEANUP">
                        <Button.Effect>
                            <DropShadowEffect Color="#FF00FF" BlurRadius="15" ShadowDepth="0"/>
                        </Button.Effect>
                    </Button>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

    $reader = [System.Xml.XmlReader]::Create((New-Object System.IO.StringReader($xaml)))
    $window = [Windows.Markup.XamlReader]::Load($reader)

    $window.Add_MouseLeftButtonDown({ $window.DragMove() })

    $headerTxt = $window.FindName("HeaderTxt")
    $warningTitleTxt = $window.FindName("WarningTitleTxt")
    $warningBodyTxt = $window.FindName("WarningBodyTxt")
    $langBtn = $window.FindName("LangBtn")
    $okBtn = $window.FindName("OkBtn")
    $cancelBtn = $window.FindName("CancelBtn")

    $script:isEnglish = $true

    $langBtn.Add_Click({
            if ($script:isEnglish) {
                $headerTxt.Text = "★ SYSTEM-ÜBERSCHREIBUNG ★"
                $warningTitleTxt.Text = "⚠️ DATENBEREINIGUNG GESTARTET"
                $warningBodyTxt.Text = "System-Cache Fragmente erkannt. Protokoll zum Löschen der Verzeichnisse 'cache', 'server-cache' und 'priv' wird ausgeführt. FiveM startet nach Abschluss neu."
                $okBtn.Content = "CLEANUP AUSFÜHREN"
                $cancelBtn.Content = "ABBRECHEN"
                $langBtn.Content = "🌐 ENGLISH"
                $script:isEnglish = $false
            }
            else {
                $headerTxt.Text = "★ SYSTEM OVERRIDE ★"
                $warningTitleTxt.Text = "⚠️ DATA PURGE INITIALIZED"
                $warningBodyTxt.Text = "System cache detected as fragmented. Initializing protocol to wipe 'cache', 'server-cache' and 'priv' directories. FiveM will reboot post-execution."
                $okBtn.Content = "EXECUTE CLEANUP"
                $cancelBtn.Content = "ABORT"
                $langBtn.Content = "🌐 DEUTSCH"
                $script:isEnglish = $true
            }
        })

    $okBtn.Add_Click({ $window.DialogResult = $true; $window.Close() })
    $cancelBtn.Add_Click({ $window.DialogResult = $false; $window.Close() })

    if ($window.ShowDialog() -ne $true) { exit }
}
catch { exit }

# --- Execution Logic (FiveM) ---
Get-Process "FiveM", "CitizenFX", "CefSharp.BrowserSubprocess" | Stop-Process -Force
Start-Sleep -Milliseconds 800

$BaseDataPath = Join-Path $env:LOCALAPPDATA "FiveM\FiveM.app\data"
"cache", "server-cache", "server-cache-priv" | ForEach-Object {
    $p = Join-Path $BaseDataPath $_
    if (Test-Path $p) { Remove-Item $p -Recurse -Force }
}

$lnk = Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs", "$env:ProgramData\Microsoft\Windows\Start Menu\Programs" -Filter "*FiveM*.lnk" -Recurse | Select-Object -First 1
if ($lnk) { Start-Process $lnk.FullName }

exit
