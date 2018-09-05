global class AttributeMatrixInfoCacheBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    String matrixRowQuery;
    List<String> errorMessageList = new List<String>();
    String cachePartition;
    Decimal stepSequence;
    String pricingPlanCode;
    vlocity_cmt__PricingPlan__c pricingPlan;
    Map<String, Object> stepParameters;
    Set<String> rangeFields;
    Set<String> rangeAttrs;
    Map<String, Object> rangeAttrMapping = new Map<String, Object>();
    Map<String, Object> rangeFieldMapping = new Map<String, Object>();
    Map<String, Object> productCodeMapping = new Map<String, Object>();
    Map<String, Object> cacheMap = new Map<String, Object>();
    Id matrixVersionId;
    String matrixName;

    global AttributeMatrixInfoCacheBatch(Map<String, Object> input) {
        cachePartition = PricingPlanHelper.getAttrMatrixInfoCachePartition();
        pricingPlanCode = (String)input.get('PricingPlanCode');
        Object sequence = input.get('PricingPlanStepSequence');

        if (String.isBlank(cachePartition))
        {
            throw new AttributeMatrixInfoCacheBatchException('No CachePartitionName parameter specified.');
        }
        if (String.isNotBlank(pricingPlanCode))
        {
            if (sequence instanceof String)
            {
                stepSequence = Decimal.valueOf((String)sequence);
            }
            else if (sequence instanceof Decimal)
            {
                stepSequence = (Decimal)sequence;
            }
            List<vlocity_cmt__PricingPlan__c> defaultPricingPlanList = [SELECT Id, Name, vlocity_cmt__Code__c, (SELECT Id, Name, vlocity_cmt__Sequence__c, vlocity_cmt__ImplementationName__c, vlocity_cmt__MethodName__c, vlocity_cmt__IsActive__c, vlocity_cmt__Parameters__c FROM vlocity_cmt__PricingPlanSteps__r WHERE vlocity_cmt__Sequence__c = :stepSequence) FROM vlocity_cmt__PricingPlan__c WHERE vlocity_cmt__Code__c = :pricingPlanCode];
            if (defaultPricingPlanList != null && !defaultPricingPlanList.isEmpty())
            {
                pricingPlan = defaultPricingPlanList[0];
            }
        }

        if (pricingPlan != null && pricingPlan.vlocity_cmt__PricingPlanSteps__r != null && !pricingPlan.vlocity_cmt__PricingPlanSteps__r.isEmpty())
        {
            if (String.isNotBlank(pricingPlan.vlocity_cmt__PricingPlanSteps__r[0].vlocity_cmt__Parameters__c))
            {
                stepParameters = (Map<String, Object>)JSON.deserializeUntyped(pricingPlan.vlocity_cmt__PricingPlanSteps__r[0].vlocity_cmt__Parameters__c);
            }
        }
        if (stepParameters != null)
        {
            System.debug('stepParameters: ' + JSON.serialize(stepParameters));
            Map<String, Object> matrixInfoOutput = new Map<String, Object>();
            PricingPlanHelper.getMatrixInfo(stepParameters, matrixInfoOutput);
            rangeFields = (Set<String>)matrixInfoOutput.get('RangeFields');
            rangeAttrs = (Set<String>)matrixInfoOutput.get('RangeAttributes');
            matrixRowQuery = (String)matrixInfoOutput.get('MatrixRowQuery');
            matrixVersionId = (Id)matrixInfoOutput.get('MatrixVersionId');
            matrixName = (String)matrixInfoOutput.get('MatrixName');
            cacheMap.put('MatrixName', matrixName);
            cacheMap.put('MatrixVersionId', matrixVersionId);
            cacheMap.put('MatrixVersionNumber', matrixInfoOutput.get('MatrixVersionNumber'));
            cacheMap.put('MatrixPriority', matrixInfoOutput.get('MatrixPriority'));
            cacheMap.put('RangeFields', rangeFields);
            cacheMap.put('RangeAttributes', rangeAttrs);
            System.debug('matrixInfoOutput: ' + JSON.serialize(matrixInfoOutput));
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(matrixRowQuery);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        try
        {
            for (SObject sObj : scope)
            {
                vlocity_cmt__CalculationMatrixRow__c cmr = (vlocity_cmt__CalculationMatrixRow__c)sObj;
                PricingPlanHelper.processMatrixRow(cmr, rangeAttrs, rangeAttrMapping, rangeFields, rangeFieldMapping, productCodeMapping);
            }
        }
        catch(Exception e)
        {
            errorMessageList.add('Exception caught: ' + e.getMessage());
            System.debug(e);
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        cacheMap.put('RangeAttrMapping', rangeAttrMapping);
        cacheMap.put('RangeFieldMapping', rangeFieldMapping);
        cacheMap.put('ProductCodeMapping', productCodeMapping);
        cacheMap.put('CacheTime', DateTime.now());
        System.debug('cacheMap: ' + JSON.serialize(cacheMap));
        Cache.OrgPartition orgPart = Cache.Org.getPartition(cachePartition);
        if (orgPart != null) {
            String cacheKey = 'AttrMatrixInfo' + String.valueOf(matrixVersionId);
            System.debug('cacheKey: ' + cacheKey);
            orgPart.put(cacheKey, cacheMap);
        }
        else
        {
            errorMessageList.add(cachePartition + 'not found.');
        }

        notifyUser(BC, null);
    }

    private void notifyUser(Database.BatchableContext BC, Map<String, Object> options){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        String userEmail = Job.CreatedBy.Email;
        if (String.isNotBlank(userEmail))
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {userEmail};
            mail.setToAddresses(toAddresses);
            String body;
            mail.setSubject('AttributeMatrixInfoCacheBatch (' + bc.getJobId() + ') ' + job.Status);
            body = 'AttributeMatrixInfoCacheBatch ('+ bc.getJobId() +') ';
            if(errorMessageList.isEmpty())
            {
                body = body + 'is successful.';
            }
            else
            {
                body = body + 'has errors. ' + String.join(errorMessageList, ' \n') + '.';
            }
            
            mail.setPlainTextBody(body);
            try
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(Exception ex)
            {
                System.debug('The following exception has occurred: ' + ex.getMessage());
            }
        }
    }

    global class AttributeMatrixInfoCacheBatchException extends Exception{}
}