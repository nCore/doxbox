unit FreeOTFEfmeOptions_Advanced;

interface

uses
  Classes, CommonfmeOptions_Base,
  Controls, Dialogs, ExtCtrls, Forms,
  FreeOTFEfmeOptions_Base, FreeOTFESettings, Graphics, Messages, SDUStdCtrls, Spin64,
  StdCtrls, SysUtils, Variants, Windows;

type
  TfmeOptions_FreeOTFEAdvanced = class (TfmeFreeOTFEOptions_Base)
    gbAdvanced:                 TGroupBox;
    lblDragDrop:                TLabel;
    ckAllowMultipleInstances:   TSDUCheckBox;
    cbDragDrop:                 TComboBox;
    ckAutoStartPortable:        TSDUCheckBox;
    ckAdvancedMountDlg:         TSDUCheckBox;
    ckRevertVolTimestamps:      TSDUCheckBox;
    pnlVertSplit:               TPanel;
    seMRUMaxItemCount:          TSpinEdit64;
    lblMRUMaxItemCountInst:     TLabel;
    lblMRUMaxItemCount:         TLabel;
    ckWarnBeforeForcedDismount: TSDUCheckBox;
    lblOnNormalDismountFail:    TLabel;
    cbOnNormalDismountFail:     TComboBox;
    cbDefaultMountAs:           TComboBox;
    lblDefaultMountAs:          TLabel;
    cbOnExitWhenMounted:        TComboBox;
    lblOnExitWhenMounted:       TLabel;
    cbOnExitWhenPortableMode:   TComboBox;
    lblOnExitWhenPortableMode:  TLabel;
    ckAllowNewlinesInPasswords: TSDUCheckBox;
    ckAllowTabsInPasswords:     TSDUCheckBox;
    procedure ControlChanged(Sender: TObject);
  PRIVATE

  PROTECTED
    procedure _ReadSettings(config: TFreeOTFESettings); OVERRIDE;
    procedure _WriteSettings(config: TFreeOTFESettings); OVERRIDE;
  PUBLIC
    procedure Initialize(); OVERRIDE;
    procedure EnableDisableControls(); OVERRIDE;
  end;

implementation

{$R *.dfm}

uses
  CommonfrmOptions,
  CommonSettings,
  OTFEFreeOTFEBase_U, SDUDialogs,
  SDUGeneral,
  SDUi18n;

const
  CONTROL_MARGIN_LBL_TO_CONTROL = 5;

resourcestring
  USE_DEFAULT = 'Use default';

procedure TfmeOptions_FreeOTFEAdvanced.ControlChanged(Sender: TObject);
begin
  inherited;
  EnableDisableControls();
end;

procedure TfmeOptions_FreeOTFEAdvanced.EnableDisableControls();
begin
  inherited;

  // Do nothing
end;

procedure TfmeOptions_FreeOTFEAdvanced.Initialize();
const
  // Vertical spacing between checkboxes, and min horizontal spacing between
  // checkbox label and the vertical separator line  
  // Set to 6 for now as that looks reasonable. 10 is excessive, 5 is a bit
  // cramped
  CHKBOX_CONTROL_MARGIN = 6;

  // Min horizontal spacing between label and control to the right of it
  LABEL_CONTROL_MARGIN = 10;

  // This adjusts the width of a checkbox, and resets it caption so it
  // autosizes. If it autosizes such that it's too wide, it'll drop the width
  // and repeat
  procedure NudgeCheckbox(chkBox: TCheckBox);
  var
    tmpCaption:     String;
    maxWidth:       Integer;
    useWidth:       Integer;
    lastTriedWidth: Integer;
  begin
    tmpCaption := chkBox.Caption;

    maxWidth := (pnlVertSplit.left - CHKBOX_CONTROL_MARGIN) - chkBox.Left;
    useWidth := maxWidth;

    chkBox.Caption := 'X';
    chkBox.Width   := useWidth;
    lastTriedWidth := useWidth;
    chkBox.Caption := tmpCaption;
    while ((chkBox.Width > maxWidth) and (lastTriedWidth > 0)) do begin
      // 5 used here; just needs to be something sensible to reduce the
      // width by; 1 would do pretty much just as well
      useWidth := useWidth - 5;

      chkBox.Caption := 'X';
      chkBox.Width   := useWidth;
      lastTriedWidth := useWidth;
      chkBox.Caption := tmpCaption;
    end;

  end;

  procedure NudgeFocusControl(lbl: TLabel);
  begin
    if (lbl.FocusControl <> nil) then begin
      lbl.FocusControl.Top := lbl.Top + lbl.Height + CONTROL_MARGIN_LBL_TO_CONTROL;
    end;

  end;

  procedure NudgeLabel(lbl: TLabel);
  var
    maxWidth: Integer;
  begin
    if (pnlVertSplit.left > lbl.left) then begin
      maxWidth := (pnlVertSplit.left - LABEL_CONTROL_MARGIN) - lbl.left;
    end else begin
      maxWidth := (lbl.Parent.Width - LABEL_CONTROL_MARGIN) - lbl.left;
    end;

    lbl.Width := maxWidth;
  end;

var
  stlChkBoxOrder: TStringList;
  YPos:           Integer;
  i:              Integer;
  currChkBox:     TCheckBox;
  groupboxMargin: Integer;
begin
  inherited;

  SDUCenterControl(gbAdvanced, ccHorizontal);
  SDUCenterControl(gbAdvanced, ccVertical, 25);

  // Re-jig label size to take cater for differences in translation lengths
  // Size so the max. right is flush with the max right of pbLangDetails
  //  lblDragDrop.width        := (pbLangDetails.left + pbLangDetails.width) - lblDragDrop.left;
  //  lblMRUMaxItemCount.width := (pbLangDetails.left + pbLangDetails.width) - lblMRUMaxItemCount.left;
  groupboxMargin           := ckAutoStartPortable.left;
  lblDragDrop.Width        := (gbAdvanced.Width - groupboxMargin) - lblDragDrop.left;
  lblMRUMaxItemCount.Width := (gbAdvanced.Width - groupboxMargin) - lblMRUMaxItemCount.left;

  pnlVertSplit.Caption    := '';
  pnlVertSplit.bevelouter := bvLowered;
  pnlVertSplit.Width      := 3;

  // Here we re-jig the checkboxes so that they are nicely spaced vertically.
  // This is needed as some language translation require the checkboxes to have
  // more than one line of text
  //
  // !! IMPORTANT !!
  // When adding a checkbox:
  //   1) Add it to stlChkBoxOrder below (doesn't matter in which order these
  //      are added)
  //   2) Make sure the checkbox is a TSDUCheckBox, not just a normal Delphi
  //      TCheckBox
  //   3) Make sure it's autosize property is TRUE
  //
  stlChkBoxOrder := TStringList.Create();
  try
    // stlChkBoxOrder is used to order the checkboxes in their vertical order;
    // this allows checkboxes to be added into the list below in *any* order,
    // and it'll still work
    stlChkBoxOrder.Sorted := True;

    stlChkBoxOrder.AddObject(Format('%.5d', [ckAllowMultipleInstances.Top]),
      ckAllowMultipleInstances);
    stlChkBoxOrder.AddObject(Format('%.5d', [ckAutoStartPortable.Top]), ckAutoStartPortable);
    stlChkBoxOrder.AddObject(Format('%.5d', [ckAdvancedMountDlg.Top]), ckAdvancedMountDlg);
    stlChkBoxOrder.AddObject(Format('%.5d', [ckRevertVolTimestamps.Top]),
      ckRevertVolTimestamps);
    stlChkBoxOrder.AddObject(Format('%.5d', [ckWarnBeforeForcedDismount.Top]),
      ckWarnBeforeForcedDismount);
    stlChkBoxOrder.AddObject(Format('%.5d', [ckAllowNewlinesInPasswords.Top]),
      ckAllowNewlinesInPasswords);
    stlChkBoxOrder.AddObject(Format('%.5d', [ckAllowTabsInPasswords.Top]),
      ckAllowTabsInPasswords);

    currChkBox := TCheckBox(stlChkBoxOrder.Objects[0]);
    YPos       := currChkBox.Top;
    YPos       := YPos + currChkBox.Height;
    for i := 1 to (stlChkBoxOrder.Count - 1) do begin
      currChkBox := TCheckBox(stlChkBoxOrder.Objects[i]);

      currChkBox.Top := YPos + CHKBOX_CONTROL_MARGIN;

      // Sort out the checkbox's height
      NudgeCheckbox(currChkBox);

      YPos := currChkBox.Top;
      YPos := YPos + currChkBox.Height;
    end;

  finally
    stlChkBoxOrder.Free();
  end;

  // Nudge labels so they're as wide as can be allowed
  NudgeLabel(lblOnExitWhenMounted);
  NudgeLabel(lblOnExitWhenPortableMode);
  NudgeLabel(lblOnNormalDismountFail);
  NudgeLabel(lblDragDrop);
  NudgeLabel(lblMRUMaxItemCount);
  NudgeLabel(lblMRUMaxItemCountInst);
  NudgeLabel(lblDefaultMountAs);

  // Here we move controls associated with labels, such that they appear
  // underneath the label
  //  NudgeFocusControl(lblLanguage);
  NudgeFocusControl(lblDragDrop);
  //  NudgeFocusControl(lblDefaultDriveLetter);
  //  NudgeFocusControl(lblMRUMaxItemCount);

end;

procedure TfmeOptions_FreeOTFEAdvanced._ReadSettings(config: TFreeOTFESettings);
var
  owem:   eOnExitWhenMounted;
  owrp:   eOnExitWhenPortableMode;
  ondf:   eOnNormalDismountFail;
  ma:     TFreeOTFEMountAs;
  ft:     TDragDropFileType;
  idx:    Integer;
  useIdx: Integer;
begin
  // Advanced...
  ckAllowMultipleInstances.Checked   := config.OptAllowMultipleInstances;
  ckAutoStartPortable.Checked        := config.OptAutoStartPortable;
  ckAdvancedMountDlg.Checked         := config.OptAdvancedMountDlg;
  ckRevertVolTimestamps.Checked      := config.OptRevertVolTimestamps;
  ckWarnBeforeForcedDismount.Checked := config.OptWarnBeforeForcedDismount;
  ckAllowNewlinesInPasswords.Checked := config.OptAllowNewlinesInPasswords;
  ckAllowTabsInPasswords.Checked     := config.OptAllowTabsInPasswords;

  // Populate and set action on exiting when volumes mounted
  cbOnExitWhenMounted.Items.Clear();
  idx    := -1;
  useIdx := -1;
  for owem := low(owem) to high(owem) do begin
    Inc(idx);
    cbOnExitWhenMounted.Items.Add(OnExitWhenMountedTitle(owem));
    if (config.OptOnExitWhenMounted = owem) then begin
      useIdx := idx;
    end;
  end;
  cbOnExitWhenMounted.ItemIndex := useIdx;

  // Populate and set action on exiting when in portable mode
  cbOnExitWhenPortableMode.Items.Clear();
  idx    := -1;
  useIdx := -1;
  for owrp := low(owrp) to high(owrp) do begin
    Inc(idx);
    cbOnExitWhenPortableMode.Items.Add(OnExitWhenPortableModeTitle(owrp));
    if (config.OptOnExitWhenPortableMode = owrp) then begin
      useIdx := idx;
    end;
  end;
  cbOnExitWhenPortableMode.ItemIndex := useIdx;

  // Populate and set action when normal dismount fails
  cbOnNormalDismountFail.Items.Clear();
  idx    := -1;
  useIdx := -1;
  for ondf := low(ondf) to high(ondf) do begin
    Inc(idx);
    cbOnNormalDismountFail.Items.Add(OnNormalDismountFailTitle(ondf));
    if (config.OptOnNormalDismountFail = ondf) then begin
      useIdx := idx;
    end;
  end;
  cbOnNormalDismountFail.ItemIndex := useIdx;

  // Populate and set default mount type
  cbDefaultMountAs.Items.Clear();
  idx    := -1;
  useIdx := -1;
  for ma := low(ma) to high(ma) do begin
    if (ma = fomaUnknown) then begin
      continue;
    end;

    Inc(idx);
    cbDefaultMountAs.Items.Add(FreeOTFEMountAsTitle(ma));
    if (config.OptDefaultMountAs = ma) then begin
      useIdx := idx;
    end;
  end;
  cbDefaultMountAs.ItemIndex := useIdx;

  // Populate and set drag drop filetype dropdown
  cbDragDrop.Items.Clear();
  idx    := -1;
  useIdx := -1;
  for ft := low(ft) to high(ft) do begin
    Inc(idx);
    cbDragDrop.Items.Add(DragDropFileTypeTitle(ft));
    if (config.OptDragDropFileType = ft) then begin
      useIdx := idx;
    end;
  end;
  cbDragDrop.ItemIndex := useIdx;

  seMRUMaxItemCount.Value := config.OptMRUList.MaxItems;

end;


procedure TfmeOptions_FreeOTFEAdvanced._WriteSettings(config: TFreeOTFESettings);
var
  owem: eOnExitWhenMounted;
  owrp: eOnExitWhenPortableMode;
  ondf: eOnNormalDismountFail;
  ma:   TFreeOTFEMountAs;
  ft:   TDragDropFileType;
begin
  // Advanced...
  config.OptAllowMultipleInstances   := ckAllowMultipleInstances.Checked;
  config.OptAutoStartPortable        := ckAutoStartPortable.Checked;
  config.OptAdvancedMountDlg         := ckAdvancedMountDlg.Checked;
  config.OptRevertVolTimestamps      := ckRevertVolTimestamps.Checked;
  config.OptWarnBeforeForcedDismount := ckWarnBeforeForcedDismount.Checked;
  config.OptAllowNewlinesInPasswords := ckAllowNewlinesInPasswords.Checked;
  config.OptAllowTabsInPasswords     := ckAllowTabsInPasswords.Checked;

  // Decode action on exiting when volumes mounted
  config.OptOnExitWhenMounted := oewmPromptUser;
  for owem := low(owem) to high(owem) do begin
    if (OnExitWhenMountedTitle(owem) = cbOnExitWhenMounted.Items[cbOnExitWhenMounted.ItemIndex])
    then begin
      config.OptOnExitWhenMounted := owem;
      break;
    end;
  end;

  // Decode action on exiting when in portable mode
  config.OptOnExitWhenPortableMode := oewpPromptUser;
  for owrp := low(owrp) to high(owrp) do begin
    if (OnExitWhenPortableModeTitle(owrp) =
      cbOnExitWhenPortableMode.Items[cbOnExitWhenPortableMode.ItemIndex]) then begin
      config.OptOnExitWhenPortableMode := owrp;
      break;
    end;
  end;

  // Decode action when normal dismount fails
  config.OptOnNormalDismountFail := ondfPromptUser;
  for ondf := low(ondf) to high(ondf) do begin
    if (OnNormalDismountFailTitle(ondf) =
      cbOnNormalDismountFail.Items[cbOnNormalDismountFail.ItemIndex]) then begin
      config.OptOnNormalDismountFail := ondf;
      break;
    end;
  end;

  // Decode default mount type
  config.OptDefaultMountAs := fomaFixedDisk;
  for ma := low(ma) to high(ma) do begin
    if (FreeOTFEMountAsTitle(ma) = cbDefaultMountAs.Items[cbDefaultMountAs.ItemIndex]) then begin
      config.OptDefaultMountAs := ma;
      break;
    end;
  end;

  // Decode drag drop filetype
  config.OptDragDropFileType := ftPrompt;
  for ft := low(ft) to high(ft) do begin
    if (DragDropFileTypeTitle(ft) = cbDragDrop.Items[cbDragDrop.ItemIndex]) then begin
      config.OptDragDropFileType := ft;
      break;
    end;
  end;

  config.OptMRUList.MaxItems := seMRUMaxItemCount.Value;

end;

end.
