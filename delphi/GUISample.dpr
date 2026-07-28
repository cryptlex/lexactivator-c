program GUISample;

uses
  Forms,
  GUISample.MainForm in 'GUISample.MainForm.pas' {GUISampleForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGUISampleForm, GUISampleForm);
  Application.Run;
end.
