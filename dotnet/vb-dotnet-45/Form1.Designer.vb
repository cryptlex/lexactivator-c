<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()>
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()>
    Private Sub InitializeComponent()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.activateBtn = New System.Windows.Forms.Button()
        Me.activateTrialBtn = New System.Windows.Forms.Button()
        Me.statusLabel = New System.Windows.Forms.Label()
        Me.productKeyBox = New System.Windows.Forms.TextBox()
        Me.SuspendLayout()
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(40, 40)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(68, 13)
        Me.Label1.TabIndex = 0
        Me.Label1.Text = "License Key:"
        '
        'activateBtn
        '
        Me.activateBtn.Location = New System.Drawing.Point(303, 95)
        Me.activateBtn.Name = "activateBtn"
        Me.activateBtn.Size = New System.Drawing.Size(75, 23)
        Me.activateBtn.TabIndex = 1
        Me.activateBtn.Text = "Activate"
        Me.activateBtn.UseVisualStyleBackColor = True
        '
        'activateTrialBtn
        '
        Me.activateTrialBtn.Location = New System.Drawing.Point(191, 95)
        Me.activateTrialBtn.Name = "activateTrialBtn"
        Me.activateTrialBtn.Size = New System.Drawing.Size(92, 23)
        Me.activateTrialBtn.TabIndex = 2
        Me.activateTrialBtn.Text = "Activate Trial"
        Me.activateTrialBtn.UseVisualStyleBackColor = True
        '
        'statusLabel
        '
        Me.statusLabel.AutoSize = True
        Me.statusLabel.Location = New System.Drawing.Point(137, 142)
        Me.statusLabel.Name = "statusLabel"
        Me.statusLabel.Size = New System.Drawing.Size(40, 13)
        Me.statusLabel.TabIndex = 3
        Me.statusLabel.Text = "Status:"
        '
        'productKeyBox
        '
        Me.productKeyBox.Location = New System.Drawing.Point(140, 37)
        Me.productKeyBox.Name = "productKeyBox"
        Me.productKeyBox.Size = New System.Drawing.Size(238, 20)
        Me.productKeyBox.TabIndex = 4
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(409, 170)
        Me.Controls.Add(Me.productKeyBox)
        Me.Controls.Add(Me.statusLabel)
        Me.Controls.Add(Me.activateTrialBtn)
        Me.Controls.Add(Me.activateBtn)
        Me.Controls.Add(Me.Label1)
        Me.Name = "Form1"
        Me.Text = "Activation Form"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

    Friend WithEvents Label1 As Label
    Friend WithEvents activateBtn As Button
    Friend WithEvents activateTrialBtn As Button
    Friend WithEvents statusLabel As Label
    Friend WithEvents productKeyBox As TextBox
End Class
