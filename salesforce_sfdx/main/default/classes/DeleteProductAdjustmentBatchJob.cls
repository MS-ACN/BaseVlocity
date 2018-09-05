/**
 * Created by Somal on 5/24/18.
 This Batch Job will be used to clear all Pricing Adjustments which are orphan records for deleted cart line items.

List<Id> objectIds = new List<Id>();   // We expect customers to provide all the objectIds on which we want to delete orphans Order Ajustment objects.
String objectType = 'Order';  // 'Order', 'Opportunity' or 'Quote'

DeleteProductAdjustmentBatchJob removeOrphans = new DeleteProductAdjustmentBatchJob(objectType,objectIds);
ID batchInstanceId = Database.executeBatch(removeOrphans);
 */

//Check if we need this batch class to be Stateful (needed to calculate count of deleted orphan Order Adjustments objects)

public with sharing class DeleteProductAdjustmentBatchJob implements Database.Batchable<sObject>, Database.Stateful {

	public class InvalidInputException extends Exception{}

	public final String NSP;
	public String parentIdField;
	public String queryString;
	public String AdjObjType;
	public String itemField;
	public String objectType;
	public Map<Id, List<Id>> deletedIdsMap;
	private String outputString;
	private List<Id> objectIds;

	public DeleteProductAdjustmentBatchJob(String objectType, List<Id> objectIds){
		this.objectType = objectType;
		this.objectIds = objectIds;
		this.NSP = 'vlocity_cmt__';
		this.deletedIdsMap = new Map<Id,List<Id>>();

		try {
			if (objectType == null && !objectType.equals('Order') && !objectType.equals('Quote') && !objectType.equals('Opportunity')) {
				throw new InvalidInputException('Invalid ObjectType.');
			}
			if (objectIds == null || objectIds.isEmpty()) {
				throw new InvalidInputException('objectIds cannot be null.');
			}
		}
		catch(InvalidInputException e){
			System.debug(LoggingLevel.ERROR,e);
		}


		getObjectStrings(objectType);
		queryString = 'SELECT Id,'+ NSP + parentIdField +' FROM ' + NSP + AdjObjType;
		queryString += ' WHERE ' + NSP + parentIdField +' IN :objectIds AND ' + NSP + itemField + ' = NULL AND ';
		queryString += NSP + 'Source__c = \'Offer\' ORDER BY '+ NSP + parentIdField;

		System.debug(LoggingLevel.ERROR, 'Starting DeleteProductAdjustmentBatchJob. Objectids passed are [='+ String.join(objectIds,', ')+'].');
		System.debug(LoggingLevel.ERROR, 'Query String generated for DeleteProductAdjustmentBatchJob is : '+queryString);
	}

	public Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(queryString);
	}

	private void getObjectStrings(String objectType) {
		if (objectType.equals('Order')) {
			AdjObjType = 'OrderPriceAdjustment__c';
			itemField = 'OrderItemId__c';
			parentIdField = 'OrderId__c';
		}
		else if (objectType.equals('Quote')) {
			AdjObjType = 'QuotePricingAdjustment__c';
			itemfield = 'QuoteItemId__c';
			parentIdField = 'QuoteId__c';
		}
		else if (objectType.equals('Opportunity')) {
			AdjObjType = 'OpportunityPriceAdjustment__c';
			itemField = 'OpportunityLineItemId__c';
			parentIdField = 'OpportunityId__c';
		}
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		//Creating map of parentIds and corresponding list of deleted orphanIds
		for(sObject orphan : scope) {
			Id parentId = (Id)orphan.get(NSP+parentIdField);
			List<Id> getOrphanList = deletedIdsMap.get(parentId);

			if (getOrphanList == null) {
				getOrphanList = new List<Id>();
			}
			getOrphanList.add(orphan.Id);
			deletedIdsMap.put(parentId,getOrphanList);
		}

		delete scope;
	}


	public void finish(Database.BatchableContext BC) {

		String outputStringFormat = '\n{0} Id is [{1}] and corresponding {2} Adjustment Ids deleted are [{3}]';
		for (Id parentId : deletedIdsMap.keySet()) {
			outputString = String.format(outputStringFormat, new List<String>{objectType, String.valueOf(parentId), objectType, String.join(deletedIdsMap.get(parentId), ',')});
		}
		System.debug(loggingLevel.ERROR, outputString);

		//If test is running, then don't need to send email
		if(!Test.isRunningTest()) {
			AsyncApexJob job = [SELECT Id,
					Status,
					NumberOfErrors,
					JobItemsProcessed,
					TotalJobItems,
					CreatedBy.Email
					FROM AsyncApexJob
					WHERE Id = :BC.getJobId()];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String userEmail = Job.CreatedBy.Email;
			String body;

			String[] toAddresses = new String[] {userEmail};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Vlocity Product Hierarchy Batch Job  (' + BC.getJobId() + ') ' + job.Status);
			body = 'The batch Apex job processed ' + job.TotalJobItems;
			body += ' batches with ' + job.NumberOfErrors + ' failures.';
			body += outputString;
			mail.setPlainTextBody(body);
			try
			{
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			} catch (Exception ex)
			{
				System.debug('The following exception has occurred: ' + ex.getMessage());
			}

		}
	}

}