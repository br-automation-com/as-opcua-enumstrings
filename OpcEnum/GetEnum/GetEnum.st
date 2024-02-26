
PROGRAM _INIT
	StepEnumStrings;
	StepDimensions;
END_PROGRAM

PROGRAM _CYCLIC
	CASE Step OF
		tpRUNNING:
			IF (UaSrv_GetServerState() = UASS_Running) THEN	
				Step := tpCONNECT;
			END_IF
		tpCONNECT:
			fbConnect.Execute := TRUE;
			IF fbConnect.Done THEN				
				fbConnect.Execute := FALSE;
				Step := tpHANDLE;
			ELSIF fbConnect.Error THEN
				Step := tpDISCONNECT;
			END_IF			
			fbConnect();
		tpHANDLE:
			fbHandle.Execute := TRUE;
			fbHandle.ConnectionHdl := fbConnect.ConnectionHdl;
			IF fbHandle.Done THEN
				fbHandle.Execute := FALSE;
				Step := tpREAD_DIMENSION;
			ELSIF fbHandle.Error THEN
				fbHandle.Execute := FALSE;
				Step := tpDISCONNECT;
			END_IF
			fbHandle();
		tpREAD_DIMENSION:
			fbRead.NodeAddInfo.AttributeId := UAAI_ArrayDimensions;
			fbRead.NodeAddInfo.IndexRangeCount := 0;
			fbRead.NodeAddInfo.IndexRange[0].StartIndex := 0;
			fbRead.NodeAddInfo.IndexRange[0].EndIndex := 0;
			VariableRd0 := '::GetEnum:StepDimensions';
			fbRead.Execute := TRUE;
			fbRead.ConnectionHdl := fbConnect.ConnectionHdl;
			fbRead.NodeHdl := fbHandle.NodeHdl;
			IF fbRead.Done THEN
				fbRead.Execute := FALSE;
				Step := tpREAD_ENUMSTRINGS;
			ELSIF fbRead.Error  THEN
				fbRead.Execute := FALSE;
				Step := tpDISCONNECT;
			END_IF
			fbRead(Variable:= VariableRd0);			
		tpREAD_ENUMSTRINGS:
			fbRead.NodeAddInfo.AttributeId := UAAI_Value;
			fbRead.NodeAddInfo.IndexRangeCount := 0;
			fbRead.NodeAddInfo.IndexRange[0].StartIndex := 0;
			fbRead.NodeAddInfo.IndexRange[0].EndIndex := UDINT_TO_UINT(StepDimensions[0]-1);
			VariableRd0 := '::GetEnum:StepEnumStrings';
			fbRead.Execute := TRUE;
			fbRead.ConnectionHdl := fbConnect.ConnectionHdl;
			fbRead.NodeHdl := fbHandle.NodeHdl;
			IF fbRead.Done THEN
				fbRead.Execute := FALSE;
				Step := tpDISCONNECT;
			ELSIF fbRead.Error  THEN
				fbRead.Execute := FALSE;
				Step := tpDISCONNECT;
			END_IF
			fbRead(Variable:= VariableRd0);	
		tpDISCONNECT:
			fbDisconnect.ConnectionHdl := fbConnect.ConnectionHdl;
			fbDisconnect.Execute := TRUE;
			IF fbDisconnect.Done OR fbDisconnect.Error THEN
				fbDisconnect.Execute := FALSE;
				Step := tpREADY;
			END_IF
			fbDisconnect();
		tpREADY:
			;
	END_CASE
	 
END_PROGRAM

PROGRAM _EXIT
	fbDisconnect.ConnectionHdl := fbConnect.ConnectionHdl;
	fbDisconnect.Execute := TRUE;
	fbDisconnect();
END_PROGRAM

