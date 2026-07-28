namespace Sample
{
    partial class ActivationForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.label1 = new System.Windows.Forms.Label();
            this.productKeyBox = new System.Windows.Forms.TextBox();
            this.activateBtn = new System.Windows.Forms.Button();
            this.activateTrialBtn = new System.Windows.Forms.Button();
            this.statusLabel = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(60, 46);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(68, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "License Key:";
            // 
            // productKeyBox
            // 
            this.productKeyBox.Location = new System.Drawing.Point(143, 43);
            this.productKeyBox.Name = "productKeyBox";
            this.productKeyBox.Size = new System.Drawing.Size(253, 20);
            this.productKeyBox.TabIndex = 1;
            // 
            // activateBtn
            // 
            this.activateBtn.Location = new System.Drawing.Point(321, 106);
            this.activateBtn.Name = "activateBtn";
            this.activateBtn.Size = new System.Drawing.Size(75, 23);
            this.activateBtn.TabIndex = 2;
            this.activateBtn.Text = "Activate";
            this.activateBtn.UseVisualStyleBackColor = true;
            this.activateBtn.Click += new System.EventHandler(this.activateBtn_Click);
            // 
            // activateTrialBtn
            // 
            this.activateTrialBtn.Location = new System.Drawing.Point(209, 106);
            this.activateTrialBtn.Name = "activateTrialBtn";
            this.activateTrialBtn.Size = new System.Drawing.Size(95, 23);
            this.activateTrialBtn.TabIndex = 3;
            this.activateTrialBtn.Text = "Activate Trial";
            this.activateTrialBtn.UseVisualStyleBackColor = true;
            this.activateTrialBtn.Click += new System.EventHandler(this.activateTrialBtn_Click);
            // 
            // statusLabel
            // 
            this.statusLabel.AutoSize = true;
            this.statusLabel.Location = new System.Drawing.Point(140, 151);
            this.statusLabel.Name = "statusLabel";
            this.statusLabel.Size = new System.Drawing.Size(37, 13);
            this.statusLabel.TabIndex = 4;
            this.statusLabel.Text = "Status";
            // 
            // ActivationForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(420, 176);
            this.Controls.Add(this.statusLabel);
            this.Controls.Add(this.activateTrialBtn);
            this.Controls.Add(this.activateBtn);
            this.Controls.Add(this.productKeyBox);
            this.Controls.Add(this.label1);
            this.Name = "ActivationForm";
            this.Text = "Activation Form";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox productKeyBox;
        private System.Windows.Forms.Button activateBtn;
        private System.Windows.Forms.Button activateTrialBtn;
        private System.Windows.Forms.Label statusLabel;
    }
}

