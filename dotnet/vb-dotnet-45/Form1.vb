Imports Cryptlex


Public Class Form1
    Public Sub New()

        InitializeComponent()

        Try
            'LexActivator.SetProductFile ("ABSOLUTE_PATH_OF_PRODUCT.DAT_FILE")
            LexActivator.SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE")
            LexActivator.SetProductId("PASTE_PRODUCT_ID", LexActivator.PermissionFlags.LA_USER)
            'LexActivator.SetLicenseCallback(AddressOf LicenseCallback)
            Dim status As Integer = LexActivator.IsLicenseGenuine()

            If status = LexStatusCodes.LA_OK OrElse status = LexStatusCodes.LA_EXPIRED OrElse status = LexStatusCodes.LA_SUSPENDED OrElse status = LexStatusCodes.LA_GRACE_PERIOD_OVER Then
                Dim expiryDate As UInteger = LexActivator.GetLicenseExpiryDate()
                Dim daysLeft As Integer = CInt((CLng(expiryDate) - CLng(unixTimestamp())) \ 86400)
                Me.statusLabel.Text = "License activation status: " & status.ToString()
                Me.activateBtn.Text = "Deactivate"
                Me.activateTrialBtn.Enabled = False
                Return
            End If

            status = LexActivator.IsTrialGenuine()

            If status = LexStatusCodes.LA_OK Then
                Dim trialExpiryDate As UInteger = LexActivator.GetTrialExpiryDate()
                Dim daysLeft As Integer = CInt((CLng(trialExpiryDate) - CLng(unixTimestamp())) \ 86400)
                Me.statusLabel.Text = "Trial period! Days left:" & daysLeft.ToString()
                Me.activateTrialBtn.Enabled = False
            ElseIf status = LexStatusCodes.LA_TRIAL_EXPIRED Then
                Me.statusLabel.Text = "Trial has expired!"
            Else
                Me.statusLabel.Text = "Trial has not started or has been tampered: " & status.ToString()
            End If

            'Checking for software release update
            'Call SetReleaseVersion(), SetReleasePlatform() and SetReleaseChannel() before calling CheckForReleaseUpdate()
            'Release version, platform and channel must be set before checking for an update
            'LexActivator.SetReleasePlatform("RELEASE_PLATFORM")
            'LexActivator.SetReleaseChannel("RELEASE_CHANNEL")
            'LexActivator.CheckForReleaseUpdate("windows", "1.0.0", "stable", AddressOf SoftwareReleaseUpdateCallback)

        Catch ex As LexActivatorException
            Me.statusLabel.Text = "Error code: " & ex.Code.ToString() & " Error message: " + ex.Message
        End Try

    End Sub

    Public Sub activateBtn_Click(sender As Object, e As EventArgs) Handles activateBtn.Click
        Try
            Dim status As Integer

            If Me.activateBtn.Text = "Deactivate" Then
                status = LexActivator.DeactivateLicense()

                If status = LexStatusCodes.LA_OK Then
                    Me.statusLabel.Text = "License deactivated successfully"
                    Me.activateBtn.Text = "Activate"
                    Me.activateTrialBtn.Enabled = True
                    Return
                End If

                Me.statusLabel.Text = "Error deactivating license: " & status.ToString()
                Return
            End If

            LexActivator.SetLicenseKey(productKeyBox.Text)
            LexActivator.SetActivationMetadata("key1", "value1")
            status = LexActivator.ActivateLicense()

            If status = LexStatusCodes.LA_OK OrElse status = LexStatusCodes.LA_EXPIRED OrElse status = LexStatusCodes.LA_SUSPENDED Then
                Me.statusLabel.Text = "Activation Successful :" & status.ToString()
                Me.activateBtn.Text = "Deactivate"
                Me.activateTrialBtn.Enabled = False
            Else
                Me.statusLabel.Text = "Error activating the license: " & status.ToString()
                Return
            End If

        Catch ex As LexActivatorException
            Me.statusLabel.Text = "Error code: " & ex.Code.ToString() & " Error message: " + ex.Message
        End Try
    End Sub

    Public Sub activateTrialBtn_Click(sender As Object, e As EventArgs) Handles activateTrialBtn.Click
        Try
            LexActivator.SetTrialActivationMetadata("key2", "value2")
            Dim status As Integer = LexActivator.ActivateTrial()

            If status <> LexStatusCodes.LA_OK Then
                Me.statusLabel.Text = "Error activating the trial: " & status.ToString()
                Return
            Else
                Me.statusLabel.Text = "Trial started successfully"
            End If

        Catch ex As LexActivatorException
            Me.statusLabel.Text = "Error code: " & ex.Code.ToString() & " Error message: " + ex.Message
        End Try
    End Sub

    Private Sub LicenseCallback(ByVal status As UInteger)
        ' NOTE: Don't invoke IsLicenseGenuine(), ActivateLicense() or ActivateTrial() API functions in this callback
        Select Case status
            Case LexStatusCodes.LA_SUSPENDED
                Me.statusLabel.Text = "The license has been suspended."
            Case Else
                Me.statusLabel.Text = "License status code: " & status.ToString()
        End Select
    End Sub

    Private Function unixTimestamp() As UInteger
        Return CUInt((DateTime.UtcNow.Subtract(New DateTime(1970, 1, 1))).TotalSeconds)
    End Function

    Private Sub SoftwareReleaseUpdateCallback(ByVal status As UInteger)
        Select Case status
            Case LexStatusCodes.LA_RELEASE_UPDATE_AVAILABLE
                Me.statusLabel.Text = "An update is available for the app."
            Case LexStatusCodes.LA_RELEASE_UPDATE_NOT_AVAILABLE
                ' Current version is latest
            Case Else
                Me.statusLabel.Text = "Release status code: " & status.ToString()
        End Select
    End Sub

End Class
