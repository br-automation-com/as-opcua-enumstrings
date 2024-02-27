
PROGRAM _INIT
	StepEnumStrings;
	StepDimensions;
	StepDataType;
	ST_name(0,ADR(TaskName),ADR(grp));
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
				Step := tpHANDLE_VARIABLE;
			ELSIF fbConnect.Error THEN
				fbConnect.Execute := FALSE;				
				Step := tpDISCONNECT;
			END_IF			
			fbConnect();			
		tpHANDLE_VARIABLE:
			fbHandle.Execute := TRUE;
			fbHandle.ConnectionHdl := fbConnect.ConnectionHdl;
			fbHandle.NodeID.NamespaceIndex := 6;
			fbHandle.NodeID.IdentifierType := UAIdentifierType_String;
			fbHandle.NodeID.Identifier := '::Program:Step';
			IF fbHandle.Done THEN
				Step := tpREAD_DATATYPE;
				fbHandle.Execute := FALSE;
			ELSIF fbHandle.Error THEN
				fbHandle.Execute := FALSE;
				Step := tpDISCONNECT;
			END_IF
			fbHandle();			
		tpREAD_DATATYPE:
			fbRead.NodeAddInfo.AttributeId := UAAI_DataType;
			fbRead.NodeAddInfo.IndexRangeCount := 0;
			fbRead.NodeAddInfo.IndexRange[0].StartIndex := 0;
			fbRead.NodeAddInfo.IndexRange[0].EndIndex := 0;
			VariableRd0 := ':StepDataType';
			VariableRd0 := INSERT(VariableRd0,TaskName,0);
			fbRead.Execute := TRUE;
			fbRead.ConnectionHdl := fbConnect.ConnectionHdl;
			fbRead.NodeHdl := fbHandle.NodeHdl;
			IF fbRead.Done THEN
				fbRead.Execute := FALSE;
				Step := tpTRANSLATE;
			ELSIF fbRead.Error  THEN
				fbRead.Execute := FALSE;
				Step := tpDISCONNECT;
			END_IF
			fbRead(Variable:= VariableRd0);				
		tpTRANSLATE:
			fbTranslate.Execute := TRUE;		
			fbTranslate.ConnectionHdl := fbConnect.ConnectionHdl;
			fbTranslate.StartNodeID := StepDataType;
			fbTranslate.RelativePath := '/0:EnumStrings';			
			IF fbTranslate.Done THEN			
				fbTranslate.Execute := FALSE;
				fbHandle.NodeID := fbTranslate.TargetNodeID;
				Step := tpHANDLE;
			ELSIF fbTranslate.Error THEN			
				fbTranslate.Execute := FALSE;
				Step := tpDISCONNECT;
			END_IF
			fbTranslate();
		tpHANDLE:
			fbHandle.Execute := TRUE;
			fbHandle.ConnectionHdl := fbConnect.ConnectionHdl;
			IF fbHandle.Done THEN
				Step := tpREAD_DIMENSIONS;
				fbHandle.Execute := FALSE;
			ELSIF fbHandle.Error THEN
				fbHandle.Execute := FALSE;
				Step := tpDISCONNECT;
			END_IF
			fbHandle();
		tpREAD_DIMENSIONS:
			fbRead.NodeAddInfo.AttributeId := UAAI_ArrayDimensions;
			fbRead.NodeAddInfo.IndexRangeCount := 0;
			fbRead.NodeAddInfo.IndexRange[0].StartIndex := 0;
			fbRead.NodeAddInfo.IndexRange[0].EndIndex := 0;
			VariableRd0 := ':StepDimensions';
			VariableRd0 := INSERT(VariableRd0,TaskName,0);
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
			VariableRd0 := ':StepEnumStrings';
			VariableRd0 := INSERT(VariableRd0,TaskName,0);	
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

