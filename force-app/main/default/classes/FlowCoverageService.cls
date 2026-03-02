global class FlowCoverageService {
   
    @InvocableMethod
    public static void isFlowCovered(List<String> parameters) {
        String flowDescriptionAndName = 'FlowCoverageStep';
        Decimal requiredPrecentage = 75;
        List<String> coveredFlowList = new List<String>();
        if(parameters != null && parameters.size() > 0) {
            List<Flosum__Metadata_Log__c> logList = [
                SELECT Id, 
                    Name,
                    Flosum__Branch__c,
                    Flosum__Organisation__c,
                    Flosum__Process_Type__c,
                    Flosum__PipelineStepId__c,
                    Flosum__PipelineStepId__r.Flosum__Description__c,
                    Flosum__Order__c,
                    Flosum__Options__c,
                    Flosum__Succeed__c,
                    Flosum__Status__c,
                    Flosum__Job_Completed__c,
                    Flosum__Batch_Job_Id__c,
                    Flosum__Automation_Completed__c
                FROM Flosum__Metadata_Log__c WHERE Id=:parameters[0]
                AND Flosum__PipelineStepId__r.Flosum__Description__c=:flowDescriptionAndName
            ];
            if(logList.size() > 0) {
                Flosum__Metadata_Log__c mdl = logList[0];
                String pipeExecId = '';
                String mergeSetName = '';
                String manualStepId = '';
                if (mdl.Flosum__Options__c != null) {
                    Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(mdl.Flosum__Options__c);
                    pipeExecId = (String)parsed.get('pipeExec');
                    mergeSetName = (String)parsed.get('mergeSetName');
                    manualStepId = (String)parsed.get('manualStepId');
                }
                List<Flosum__PipelineStepsResult__c> pipelineStepResults = [
                    SELECT Id,
                        Flosum__Pipeline_Execution__c,
                        Flosum__Pipeline_Id__c,
                        Flosum__PipelineSteps__c,
                        Flosum__Step_Number__c,
                        Flosum__Org_Id__c
                    FROM Flosum__PipelineStepsResult__c
                    WHERE Flosum__Pipeline_Execution__c=:pipeExecId
                    AND Flosum__Branch_Id__c=:mdl.Flosum__Branch__c
                    AND Flosum__Org_Id__c=:mdl.Flosum__Organisation__c
                    AND Flosum__Step_Number__c <=:mdl.Flosum__Order__c
                    AND Flosum__PipelineSteps__r.Flosum__Step__c = 'Validate'
                    ORDER BY Flosum__Step_Number__c DESC LIMIT 1
                ];
                if(!pipelineStepResults.isEmpty()) {
                    List<Flosum__Metadata_Log__c> preValidateLog = [
                        SELECT Id 
                        FROM Flosum__Metadata_Log__c
                        WHERE Flosum__PipelineStepId__c=:pipelineStepResults[0].Flosum__PipelineSteps__c
                        AND Flosum__Succeed__c=true
                        AND Flosum__Job_Completed__c=true
                        AND Flosum__Batch_Job_Id__c = :mdl.Flosum__Batch_Job_Id__c
                        LIMIT 1
                    ];
                    if(!preValidateLog.isEmpty()) {
                        List<Attachment> attList = [
                            SELECT Id, Name, Body
                            FROM Attachment
                            WHERE ParentId=:preValidateLog[0].Id
                            AND Name='Code Coverage Log'
                            ORDER BY CreatedDate DESC LIMIT 1
                        ];
                        if(!preValidateLog.isEmpty()) {
                            TestResultWraper result = (TestResultWraper) JSON.deserialize(attList[0].Body.toString(), TestResultWraper.class);
                            if(result.flowCoverageWarnings != null && result.flowCoverageWarnings.size() > 0) {
                                updateMetadataLog(mdl, false, 'There are flow coverage warnings in previous validation operations on this org.');
                                return;
                            }
                            if(result.flowCoverage == null || result.flowCoverage.size() == 0) {
                                updateMetadataLog(mdl, false, 'There is no flow coverage in previous validation operations on this org.');
                                return;
                            }
                            for(FlowCoverageResult coverageResult : result.flowCoverage) {
                                Integer elementsCovered = coverageResult.numElements-coverageResult.numElementsNotCovered;
                                Decimal precentage = (elementsCovered/coverageResult.numElements)*100;
                                if(precentage < requiredPrecentage) {
                                    updateMetadataLog(mdl, false, requiredPrecentage+'% elements are not covered on the flow'+coverageResult.flowName+'. Please check the Coverage Details for more information.');
                                    return;
                                }
                            }
                            updateMetadataLog(mdl, true, null);
                            return;
                        }
                    }
                    else {
                        updateMetadataLog(mdl, false,'There is no successful validation log on the target org.');
                        return;
                    }
                }
                updateMetadataLog(mdl, false,'Flow coverage not found.');
                return;
            }
        }
    }
    
    public static void updateMetadataLog(Flosum__Metadata_Log__c mdl, Boolean isSuccess, String info) {
        mdl.Flosum__Automation_Completed__c = true;
        mdl.Flosum__Succeed__c = isSuccess;
        update mdl;
        
        Attachment att = new Attachment();
        att.Name = 'Error Log';
        att.ParentId = mdl.Id;
        att.Body = Blob.valueOf(info);
        insert att;
    }
    
    public class TestResultWraper {
        public FlowCoverageResult[] flowCoverage;
        public FlowCoverageWarning[] flowCoverageWarnings;
    }
    
    public class FlowCoverageResult {
        public String flowName;
        public String flowNamespace;
        public Integer numElements;
        public Integer numElementsNotCovered;
        public String processType;
    }

    public class FlowCoverageWarning {
        public String flowName;
        public String flowNamespace;
        public String message;
    }
}