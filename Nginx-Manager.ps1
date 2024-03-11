
#
# V1.0
# Created by craeckor
# Nginx-Manager
# A simple Powershell Windows-Forms Nginx-Manager
#

# Checks if nginx.exe is available. If not = error message
if (Test-Path ".\nginx.exe") {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Import Icon from nginx.exe
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon("nginx.exe")

    # Get current Nginx version
    $nginxv = cmd /c nginx.exe -v 2`>`&1
    $nginxv = $nginxv | ConvertFrom-String -Delimiter nginx | Select-Object -ExpandProperty P3
    $nginxv = $($nginxv -replace "/", "")

    # Function to check if nginx is running
    function CheckNginxStatus {
        $nginxProcess = Get-Process -Name nginx -ErrorAction SilentlyContinue
        if ($nginxProcess) {
            $statusLabel.ForeColor = [System.Drawing.Color]::Green
            return "Nginx is running"
        } else {
            $statusLabel.ForeColor = [System.Drawing.Color]::Red
            return "Nginx is not running"
        }
    }

    # Another function to check if nginx is running
    function CheckNginxStatus2 {
        $nginxStatus = Get-Process -Name nginx -ErrorAction SilentlyContinue
        if ($nginxStatus) {
            return $true
        } else {
            return $false
        }
    }

    # Function to execute nginx commands
    function ExecuteNginxCommand($command) {
        $isNginxrunning = CheckNginxStatus2
	    if ($isNginxrunning) {
		    Start-Process -FilePath "nginx.exe" -ArgumentList $command -NoNewWindow -Wait
            $global:wait = $true
	    } else {
		    [System.Windows.Forms.MessageBox]::Show("Nginx is not running", "Information", "OK", "Information")
            $global:wait = $false
	    }
    }

    # Function to execute nginx commands, capture the information and give the information out
    function ExecuteNginxCommandwithCapture($command) {
		$nginxoutput = cmd /c nginx.exe $command 2`>`&1
        [System.Windows.Forms.MessageBox]::Show("$nginxoutput", "Information", "OK", "Information")
    }

    # Function to start nginx
    function StartNginx {
        $isNginxrunning = CheckNginxStatus2
	    if ($isNginxrunning) {
		    [System.Windows.Forms.MessageBox]::Show("Nginx is already running", "Information", "OK", "Information")
            $global:wait = $false
	    } else {
		    Start-Process -FilePath "nginx.exe" -NoNewWindow
            $global:wait = $true
	    }
    }

    # Create a form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Nginx Manager"
    $form.Size = New-Object System.Drawing.Size(400,325)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $form.MaximizeBox = $False
    $form.Icon = $icon
    $form.ShowInTaskbar = $true
    $form.AutoScalemode = "Dpi"
    $form.AutoSize = $true

    # Create label for status
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Location = New-Object System.Drawing.Point(10,20)
    $statusLabel.Size = New-Object System.Drawing.Size(175,20)
    $statusLabel.Text = CheckNginxStatus
    $statusLabel.AutoSize = $true
    $form.Controls.Add($statusLabel)

    $nginxVersion = New-Object System.Windows.Forms.Label
    $nginxVersion.Location = New-Object System.Drawing.Point(300,20)
    $nginxVersion.Size = New-Object System.Drawing.Size(75,20)
    $nginxVersion.Text = "Nginx v$nginxv"
    $nginxVersion.AutoSize = $true
    $form.Controls.Add($nginxVersion)

    # Create label for commands
    $commandsLabel = New-Object System.Windows.Forms.Label
    $commandsLabel.Location = New-Object System.Drawing.Point(10,50)
    $commandsLabel.Size = New-Object System.Drawing.Size(175,20)
    $commandsLabel.Text = "Select a command:"
    $commandsLabel.AutoSize = $true
    $form.Controls.Add($commandsLabel)

    # Create listbox for commands
    $commandsList = New-Object System.Windows.Forms.ListBox
    $commandsList.Location = New-Object System.Drawing.Point(10,80)
    $commandsList.Size = New-Object System.Drawing.Size(210,120)
    $commandsList.Items.AddRange(@("Start Nginx", "Fast shutdown", "Kill Nginx", "Graceful shutdown", "Reload configuration", "Re-opening log files", "Show version with config options", "Test configuration"))
    $form.Controls.Add($commandsList)

    # Create button to execute command
    $executeButton = New-Object System.Windows.Forms.Button
    $executeButton.Location = New-Object System.Drawing.Point(10,210)
    $executeButton.Size = New-Object System.Drawing.Size(100,30)
    $executeButton.Text = "Execute"
    $executeButton.Add_Click({
        $selectedCommand = $commandsList.SelectedItem
        switch ($selectedCommand) {
            "Start Nginx" {
                StartNginx
                if ($global:wait) {
                    Start-Sleep -Seconds 3
                }
            }
            "Fast shutdown" {
                ExecuteNginxCommand("-s stop")
                if ($global:wait) {
                    Start-Sleep -Seconds 3
                }
            }
            "Kill Nginx" {
                $isNginxrunning = CheckNginxStatus2
	            if ($isNginxrunning) {
		            Get-Process | Where-Object { $_.ProcessName -like "nginx" } | Stop-Process -Force
                    Start-Sleep -Seconds 3
	            } else {
                    [System.Windows.Forms.MessageBox]::Show("Nginx is not running", "Information", "OK", "Information")
	            }
            }
            "Graceful shutdown" {
                ExecuteNginxCommand("-s quit")
                if ($global:wait) {
                    Start-Sleep -Seconds 3
                }
            }
            "Reload configuration" {
                ExecuteNginxCommand("-s reload")
                if ($global:wait) {
                    Start-Sleep -Seconds 3
                }
            }
            "Re-opening log files" {
                ExecuteNginxCommand("-s reopen")
                if ($global:wait) {
                    Start-Sleep -Seconds 3
                }
            }
            "Show version with config options"{
                ExecuteNginxCommandwithCapture("-V")
            }
            "Test configuration"{
                ExecuteNginxCommandwithCapture("-t")
            }
        }
        $statusLabel.Text = CheckNginxStatus
    })
    $executeButton.AutoSize = $true
    $form.Controls.Add($executeButton)

    # Create button to exit
    $exitButton = New-Object System.Windows.Forms.Button
    $exitButton.Location = New-Object System.Drawing.Point(120,210)
    $exitButton.Size = New-Object System.Drawing.Size(100,30)
    $exitButton.Text = "Exit"
    $exitButton.Add_Click({
        $form.Close()
    })
    $exitButton.AutoSize = $true
    $form.Controls.Add($exitButton)

    # Timer to check nginx status every 3 seconds
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 3000
    $timer.Add_Tick({
        $statusLabel.Text = CheckNginxStatus
    })
    $timer.Start()

    # Show the form
    $form.ShowDialog() | Out-Null
} else {
    [System.Windows.Forms.MessageBox]::Show("Nginx not found", "Error", "OK", "Error")
}