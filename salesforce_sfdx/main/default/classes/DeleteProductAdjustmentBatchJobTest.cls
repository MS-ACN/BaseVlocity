/**
 * Created by Somal on 5/25/18.
 */

@isTest(SeeAllData=false)
private class DeleteProductAdjustmentBatchJobTest {

	private static Id orderId;
	private static Id opportunityId;
	private static Id quoteId;
	private static List<Id> objectIds;
	private static Id batchId;
	private static String objectType;
	private static String nsPrefix = 'vlocity_cmt__';

	static private void setup(){

		vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
		insert itemTrigger;

		List<SObject> sObjList = new List<sObject>();
		Product2 prod1 = new Product2 (Name='Prod1');
		sObjList.add(prod1);

		Product2 prod2 = new Product2 (Name='Prod2');
		sObjList.add(prod2);

		Product2 prod3 = new Product2 (Name='Prod3');
		sObjList.add(prod3);

		insert sObjList;
		sObjList.clear();

		// Create Product Child Item
		vlocity_cmt__ProductChildItem__c pciSO0 = new vlocity_cmt__ProductChildItem__c();
		pciSO0.vlocity_cmt__ParentProductId__c = prod1.Id;
		pciSO0.vlocity_cmt__ChildProductId__c = prod2.Id;
		pciSO0.Name = 'Test PCI1';
		pciSO0.vlocity_cmt__Quantity__c = 1.0;
		pciSO0.vlocity_cmt__MinQuantity__c = 0.0;
		pciSO0.vlocity_cmt__MaxQuantity__c = 5.0;
		pciSO0.vlocity_cmt__IsRootProductChildItem__c = false;
		pciSO0.vlocity_cmt__IsOverride__c = false;
		pciSO0.vlocity_cmt__ChildLineNumber__c = '0001';
		pciSO0.vlocity_cmt__IsVirtualItem__c = false;
		sObjList.add(pciSO0);

		vlocity_cmt__ProductChildItem__c pci2 = new vlocity_cmt__ProductChildItem__c();
		pci2.vlocity_cmt__ParentProductId__c = prod2.Id;
		pci2.vlocity_cmt__ChildProductId__c = prod3.Id;
		pci2.Name = 'Test PCI2';
		pci2.vlocity_cmt__Quantity__c = 1.0;
		pci2.vlocity_cmt__MinQuantity__c = 0.0;
		pci2.vlocity_cmt__MaxQuantity__c = 5.0;
		pci2.vlocity_cmt__IsRootProductChildItem__c = false;
		pci2.vlocity_cmt__IsOverride__c = false;
		pci2.vlocity_cmt__ChildLineNumber__c = '0001';
		pci2.vlocity_cmt__IsVirtualItem__c = false;
		sObjList.add(pci2);

		insert sObjList;
		sObjList.clear();

		Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
		Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook7', IsActive = true);
		insert testPricebook;

		//Inserting into standard Pricebook
		PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = standardBook.Id,
				Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
		sObjList.add(pbe4);

		PricebookEntry pbe5 = new PricebookEntry(Pricebook2Id = standardBook.Id,
				Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true);
		sObjList.add(pbe5);

		PricebookEntry pbe6 = new PricebookEntry(Pricebook2Id = standardBook.Id,
				Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true);
		sObjList.add(pbe6);

		//insert sObjList;
		//sObjList.clear();

		//Inserting into Custom Pricebook
		PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
				Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
		sObjList.add(pbe1);

		PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
				Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true, UseStandardPrice = false);
		sObjList.add(pbe2);

		PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
				Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true, UseStandardPrice = false);
		sObjList.add(pbe3);

		insert sObjList;
		sObjList.clear();



		// Create Time Plan
		vlocity_cmt__TimePlan__c timePlan = new vlocity_cmt__TimePlan__c(Name='6 Months Time Plan', vlocity_cmt__Description__c='6 Months Time Plan', vlocity_cmt__EffectiveStartDate__c=Datetime.now(),
				vlocity_cmt__IsActive__c=true, vlocity_cmt__TotalDuration__c=6.0, vlocity_cmt__TotalDurationUoM__c='Month');
		insert timePlan;

		// Create Time Policy
		vlocity_cmt__TimePolicy__c timePolicy = new vlocity_cmt__TimePolicy__c(Name='Purchase Date - End of Plan', vlocity_cmt__Description__c='Purchase Date - End of Plan', vlocity_cmt__EffectiveStartDate__c=Datetime.now().date(),
				vlocity_cmt__EndTimePolicy__c='End of Plan Duration', vlocity_cmt__IsActive__c=true, vlocity_cmt__IsEndProratable__c=false, vlocity_cmt__IsStartProratable__c=false, vlocity_cmt__IsStartTimeDelayed__c=false, vlocity_cmt__StartTimePolicy__c='Purchase Date');
		insert timePolicy;

		vlocity_cmt__Promotion__c promo1 = new vlocity_cmt__Promotion__c(Name='Promo1', vlocity_cmt__Code__c='Promo1', vlocity_cmt__DurationTimePlanId__c=timePlan.Id, vlocity_cmt__DurationTimePolicyId__c=timePolicy.Id);
		insert promo1;

		vlocity_cmt__PromotionItem__c promoItem1 = new vlocity_cmt__PromotionItem__c(Name='PromoItem1', vlocity_cmt__PromotionId__c = promo1.Id, vlocity_cmt__ProductId__c = prod1.Id);
		insert promoItem1;

		vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
		insert pl1;

		// Create Object Type
		//Id objectRTId = ObjectTypesService.getRecordTypeId(nsPrefix + 'ObjectClass__c', 'ObjectType');
		SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
		vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
		vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
		sObjList.clear();
		sObjList.add(chargeObjType);
		sObjList.add(discObjType);
		insert sObjList;
		sObjList.clear();

		vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
				vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
				vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
		sObjList.add(oneTimeStdPriceVar);

		vlocity_cmt__PricingVariable__c mrcPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
				vlocity_cmt__ChargeType__c='Recurring', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
				vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
		sObjList.add(mrcPriceVar);
		insert sObjList;
		sObjList.clear();

		vlocity_cmt__PricingVariable__c oneTimeStdPriceVarDiscount = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price Adjustment Pct', vlocity_cmt__Code__c = 'OT_STD_PRC_ADJ_PCT',vlocity_cmt__Aggregation__c = 'Unit',
				vlocity_cmt__ChargeType__c='Adjustment',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
				vlocity_cmt__ValueType__c='Pricing Element', vlocity_cmt__CurrencyType__c='Currency', vlocity_cmt__AdjustmentMethod__c = 'Percent', vlocity_cmt__AppliesToVariableId__c=oneTimeStdPriceVar.Id);
		sObjList.add(oneTimeStdPriceVarDiscount);

		vlocity_cmt__PricingVariable__c mrcPriceVarDiscountAbs = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price Adjustment Abs', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC_ADJ_ABS',vlocity_cmt__Aggregation__c = 'Unit',
				vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
				vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency',vlocity_cmt__AppliesToVariableId__c = mrcPriceVar.Id);
		sObjList.add(mrcPriceVarDiscountAbs);
		insert sObjList;


		// Create Pricing Element
		vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = 'One Time $100 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 100.00,
				vlocity_cmt__Code__c = 'PELEM1', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
		vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = 'MRC $20 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 20.00,
				vlocity_cmt__Code__c = 'PELEM2', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
		vlocity_cmt__PricingElement__c pElem3 = new vlocity_cmt__PricingElement__c(Name = 'One Time 50% Global Discount', vlocity_cmt__ObjectTypeId__c = discObjType.Id, vlocity_cmt__AdjustmentValue__c = 50,
				vlocity_cmt__Code__c = 'PELEM3', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVarDiscount.Id, vlocity_cmt__PriceListId__c = pl1.Id);
		vlocity_cmt__PricingElement__c pElem4 = new vlocity_cmt__PricingElement__c(Name = 'One Time $400 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 400.00,
				vlocity_cmt__Code__c = 'PELEM4', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
		vlocity_cmt__PricingElement__c pElem5 = new vlocity_cmt__PricingElement__c(Name = 'MRC $50 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 50.00,
				vlocity_cmt__Code__c = 'PELEM5', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
		vlocity_cmt__PricingElement__c pElem6 = new vlocity_cmt__PricingElement__c(Name = 'MRC $70 Standalone Discount', vlocity_cmt__ObjectTypeId__c = discObjType.Id, vlocity_cmt__AdjustmentValue__c = 70.00,
				vlocity_cmt__Code__c = 'PELEM6', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = mrcPriceVarDiscountAbs.Id, vlocity_cmt__PriceListId__c = pl1.Id);
		sObjList.clear();
		sObjList.add(pElem1);
		sObjList.add(pElem2);
		sObjList.add(pElem3);
		sObjList.add(pElem4);
		sObjList.add(pElem5);
		sObjList.add(pElem6);

		insert sObjList;
		sObjList.clear();

		List<vlocity_cmt__Promotion__c> promos = [SELECT Id FROM vlocity_cmt__Promotion__c];

		List<vlocity_cmt__PricingElement__c> pricingElement = [Select Id, Name from vlocity_cmt__PricingElement__c];

		vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__PromotionId__c=promos[0].Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple1);

		vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem4.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple2);

		vlocity_cmt__PriceListEntry__c ple3 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem3.Id, vlocity_cmt__OfferId__c = prod1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple3);

		vlocity_cmt__PriceListEntry__c ple4 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem3.Id, vlocity_cmt__PromotionId__c = promos[0].Id, vlocity_cmt__OfferId__c = prod1.Id,vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple4);

		vlocity_cmt__PriceListEntry__c ple5 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod3.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple5);

		vlocity_cmt__PriceListEntry__c ple6 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod3.Id, vlocity_cmt__PricingElementId__c = pElem3.Id, vlocity_cmt__OfferId__c = prod1.Id, vlocity_cmt__PromotionId__c = promos[0].Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple6);

		vlocity_cmt__PriceListEntry__c ple7 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple7);

		vlocity_cmt__PriceListEntry__c ple8 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem4.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple8);

		vlocity_cmt__PriceListEntry__c ple9 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod3.Id, vlocity_cmt__PricingElementId__c = pElem3.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
		sObjList.add(ple9);


		insert sObjList;
		sObjList.clear();

		Account a = new Account(Name='Acct');
		insert a;

		vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
		insert iit1;
		vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingElementServiceImplementation',
				vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);
		insert iid1;

		vlocity_cmt__InterfaceImplementation__c iit012 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
		insert iit012;
		vlocity_cmt__InterfaceImplementationDetail__c iit012_001 = new vlocity_cmt__InterfaceImplementationDetail__c(Name = 'PricingElementServiceImplementation', vlocity_cmt__InterfaceId__c=iit012.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
		insert  iit012_001;


		vlocity_cmt__InterfaceImplementation__c intImpl = new vlocity_cmt__InterfaceImplementation__c (Name='TightestMatchInterface');
		insert intImpl;

		vlocity_cmt__InterfaceImplementationDetail__c iit004_001 = new vlocity_cmt__InterfaceImplementationDetail__c
				(Name = 'TightestMatchServiceImplementation', vlocity_cmt__InterfaceId__c=intImpl.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
		insert iit004_001;

		vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
		insert myTrigger;
		vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
		insert iit;
		List<vlocity_cmt__InterfaceImplementationDetail__c> iidList = new List<vlocity_cmt__InterfaceImplementationDetail__c> ();
		vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c  (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);

		iidList.add(iit_001);
		insert iidList;


		Order testOrder = new Order(Name='Test Order',EffectiveDate=System.today(),status='Draft',AccountId = a.Id, vlocity_cmt__PriceListId__c = pl1.Id, Pricebook2Id = testPricebook.Id);
		insert testOrder;
		orderId = testOrder.Id;

		List<priceBookEntry> priceBookEntry = [Select Id from PricebookEntry where Product2Id =: prod1.Id];
		Id priceBookEntryId = priceBookEntry[0].Id;

		sObjList.clear();
		OrderItem orderItem = new OrderItem();
		orderItem.OrderId = testOrder.Id;
		orderItem.PricebookEntryId = pbe1.Id;
		orderItem.Quantity = 1;
		orderItem.vlocity_cmt__LineNumber__c = '0001';
		orderItem.UnitPrice = 100;
		orderItem.vlocity_cmt__ProvisioningStatus__c = 'New';

		sObjList.add(orderItem);

		OrderItem orderItem2 = new OrderItem();
		orderItem2.OrderId = testOrder.Id;
		orderItem2.PricebookEntryId = pbe2.Id;
		orderItem2.Quantity = 1;
		orderItem2.vlocity_cmt__LineNumber__c = '0001.0001';
		orderItem2.UnitPrice = 100;
		orderItem2.vlocity_cmt__ProvisioningStatus__c = 'New';

		sObjList.add(orderItem2);

		OrderItem orderItem3 = new OrderItem();
		orderItem3.OrderId = testOrder.Id;
		orderItem3.PricebookEntryId = pbe3.Id;
		orderItem3.Quantity = 1;
		orderItem3.vlocity_cmt__LineNumber__c = '0001.0001.0001';
		orderItem3.UnitPrice = 100;
		orderItem3.vlocity_cmt__ProvisioningStatus__c = 'New';
		sObjList.add(orderItem3);

		insert sObjList;
		sObjList.clear();

		// Create Applied Promotion
		vlocity_cmt__OrderAppliedPromotion__c oap = new vlocity_cmt__OrderAppliedPromotion__c(Name='Test Applied Promo', vlocity_cmt__Action__c='Add', vlocity_cmt__OrderId__c=testOrder.Id, vlocity_cmt__PromotionId__c=promos[0].Id);
		insert oap;

		// Create Promotion Affected Items
		vlocity_cmt__OrderAppliedPromotionItem__c oapi = new vlocity_cmt__OrderAppliedPromotionItem__c(Name='OAPI1', vlocity_cmt__AppliedAction__c='Add', vlocity_cmt__MaxQuantity__c=5.0,
				vlocity_cmt__MinQuantity__c=1.0, vlocity_cmt__OrderAppliedPromotionId__c=oap.Id, vlocity_cmt__OrderItemId__c=orderItem.Id);
		sObjList.add(oapi);
		vlocity_cmt__OrderAppliedPromotionItem__c oapi2 = new vlocity_cmt__OrderAppliedPromotionItem__c(Name='OAPI2', vlocity_cmt__AppliedAction__c='Add', vlocity_cmt__MaxQuantity__c=5.0,
				vlocity_cmt__MinQuantity__c=1.0, vlocity_cmt__OrderAppliedPromotionId__c=oap.Id, vlocity_cmt__OrderItemId__c=orderItem2.Id);
		sObjList.add(oapi2);
		insert sObjList;
		sObjList.clear();

		// Create Price Adjustments
		vlocity_cmt__OrderPriceAdjustment__c opa1 = new vlocity_cmt__OrderPriceAdjustment__c(Name='OPA1', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OrderAppliedPromotionId__c=oap.Id, vlocity_cmt__OrderId__c=testOrder.Id, vlocity_cmt__OrderItemId__c=orderItem2.Id, vlocity_cmt__PriceListEntryId__c=ple4.Id,
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__PromotionId__c=promos[0].Id, vlocity_cmt__Source__c='Promotion');
		sObjList.add(opa1);
		vlocity_cmt__OrderPriceAdjustment__c opa2 = new vlocity_cmt__OrderPriceAdjustment__c(Name='OPA2', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OrderId__c=testOrder.Id, vlocity_cmt__OrderItemId__c=orderItem2.Id, vlocity_cmt__PriceListEntryId__c=ple4.Id,
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Offer');
		sObjList.add(opa2);
		vlocity_cmt__OrderPriceAdjustment__c opa3 = new vlocity_cmt__OrderPriceAdjustment__c(Name='OPA3', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OrderAppliedPromotionId__c=oap.Id, vlocity_cmt__OrderId__c=testOrder.Id, vlocity_cmt__OrderItemId__c=orderItem3.Id, vlocity_cmt__PromotionId__c=promos[0].Id,
				vlocity_cmt__PriceListEntryId__c=ple6.Id, vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Promotion');
		sObjList.add(opa3);
		vlocity_cmt__OrderPriceAdjustment__c opa4 = new vlocity_cmt__OrderPriceAdjustment__c(Name='OPA4', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-5.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OrderId__c=testOrder.Id, vlocity_cmt__OrderItemId__c=orderItem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Agent');
		sObjList.add(opa4);
		vlocity_cmt__OrderPriceAdjustment__c opa5 = new vlocity_cmt__OrderPriceAdjustment__c(Name='OPA5', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OrderAppliedPromotionId__c=oap.Id, vlocity_cmt__OrderId__c=testOrder.Id, vlocity_cmt__PromotionId__c=promos[0].Id,
				vlocity_cmt__PriceListEntryId__c=ple6.Id, vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Offer');
		sObjList.add(opa5);

		insert sObjList;
		sObjList.clear();

		// Create Opportunity
		Opportunity testOpp = new Opportunity(Name ='testOpp',
				AccountId = a.Id,
				StageName = 'test stage',
				CloseDate = Date.today(),
				vlocity_cmt__PriceListId__c = pl1.Id,
				Pricebook2Id = testPricebook.Id);

		insert testOpp;
		opportunityId = testOpp.Id;

		OpportunityLineItem op1 = new OpportunityLineItem();
		op1.OpportunityId = testOpp.Id;
		op1.PricebookEntryId = pbe1.Id;
		op1.Quantity = 1;
		op1.vlocity_cmt__LineNumber__c = '0001';
		op1.UnitPrice = 100;
		sObjList.add(op1);

		OpportunityLineItem op2 = new OpportunityLineItem();
		op2.OpportunityId = testOpp.Id;
		op2.PricebookEntryId = pbe2.Id;
		op2.Quantity = 1;
		op2.vlocity_cmt__LineNumber__c = '0001.0001';
		op2.UnitPrice = 100;
		sObjList.add(op2);

		OpportunityLineItem op3 = new OpportunityLineItem();
		op3.OpportunityId = testOpp.Id;
		op3.PricebookEntryId = pbe3.Id;
		op3.Quantity = 1;
		op3.vlocity_cmt__LineNumber__c = '0001.0001.0001';
		op3.UnitPrice = 100;
		sObjList.add(op3);

		insert sObjList;
		sObjList.clear();

		// Create Applied Promotion
		vlocity_cmt__OpportunityAppliedPromotion__c opptyap = new vlocity_cmt__OpportunityAppliedPromotion__c(Name='Test Applied Promo', vlocity_cmt__Action__c='Add', vlocity_cmt__OpportunityId__c=testOpp.Id, vlocity_cmt__PromotionId__c=promos[0].Id);
		insert opptyap;

		// Create Promotion Affected Items
		vlocity_cmt__OpportunityAppliedPromotionItem__c opptyapi = new vlocity_cmt__OpportunityAppliedPromotionItem__c(Name='OAPI1', vlocity_cmt__AppliedAction__c='Add', vlocity_cmt__MaxQuantity__c=5.0,
				vlocity_cmt__MinQuantity__c=1.0, vlocity_cmt__OpportunityAppliedPromotionId__c=opptyap.Id, vlocity_cmt__OpportunityLineItemId__c=op1.Id);
		sObjList.add(opptyapi);
		vlocity_cmt__OpportunityAppliedPromotionItem__c opptyap2 = new vlocity_cmt__OpportunityAppliedPromotionItem__c(Name='OAPI2', vlocity_cmt__AppliedAction__c='Add', vlocity_cmt__MaxQuantity__c=5.0,
				vlocity_cmt__MinQuantity__c=1.0, vlocity_cmt__OpportunityAppliedPromotionId__c=opptyap.Id, vlocity_cmt__OpportunityLineItemId__c=op2.Id);
		sObjList.add(opptyap2);
		insert sObjList;
		sObjList.clear();

		// Create Price Adjustments
		vlocity_cmt__OpportunityPriceAdjustment__c opptypa = new vlocity_cmt__OpportunityPriceAdjustment__c(Name='OPA1', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OpportunityAppliedPromotionId__c = opptyap.Id, vlocity_cmt__OpportunityId__c=testOpp.Id, vlocity_cmt__OpportunityLineItemId__c=op2.Id, vlocity_cmt__PriceListEntryId__c=ple4.Id,
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__PromotionId__c=promos[0].Id, vlocity_cmt__Source__c='Promotion');
		sObjList.add(opptypa);
		vlocity_cmt__OpportunityPriceAdjustment__c opptypa2 = new vlocity_cmt__OpportunityPriceAdjustment__c(Name='OPA2', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OpportunityId__c=testOpp.Id, vlocity_cmt__OpportunityLineItemId__c=op2.Id, vlocity_cmt__PriceListEntryId__c=ple4.Id,
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Offer');
		sObjList.add(opptypa2);
		vlocity_cmt__OpportunityPriceAdjustment__c opptypa3 = new vlocity_cmt__OpportunityPriceAdjustment__c(Name='OPA3', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OpportunityAppliedPromotionId__c = opptyap.Id, vlocity_cmt__OpportunityId__c=testOpp.Id, vlocity_cmt__OpportunityLineItemId__c=op3.Id, vlocity_cmt__PromotionId__c=promos[0].Id,
				vlocity_cmt__PriceListEntryId__c=ple6.Id, vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Promotion');
		sObjList.add(opptypa3);

		vlocity_cmt__OpportunityPriceAdjustment__c opptypa4 = new vlocity_cmt__OpportunityPriceAdjustment__c(Name='OPA4', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-5.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OpportunityId__c=testOpp.Id, vlocity_cmt__OpportunityLineItemId__c=op3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Agent',
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id);
		sObjList.add(opptypa4);
		vlocity_cmt__OpportunityPriceAdjustment__c opptypa5 = new vlocity_cmt__OpportunityPriceAdjustment__c(Name='OPA5', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-5.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__OpportunityId__c=testOpp.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Offer',
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id);
		sObjList.add(opptypa5);

		insert sObjList;
		sObjList.clear();

		// Create Quote

		Quote testQuote = new Quote (Name='Test Quote', Pricebook2Id=testPricebook.Id, OpportunityId=testOpp.Id);
		insert testQuote;
		quoteId = testQuote.Id;

		QuoteLineItem ql1 = new QuoteLineItem(QuoteId=testQuote.Id, PricebookEntryId = pbe1.Id,
				vlocity_cmt__LineNumber__c = '0001', Quantity = 1, UnitPrice = 100);

		sObjList.add(ql1);

		QuoteLineItem ql2 = new QuoteLineItem(QuoteId=testQuote.Id, PricebookEntryId = pbe2.Id,
				vlocity_cmt__LineNumber__c = '0001.0001', Quantity = 1, UnitPrice = 100);

		sObjList.add(ql2);

		QuoteLineItem ql3= new QuoteLineItem(QuoteId=testQuote.Id, PricebookEntryId = pbe3.Id,
				vlocity_cmt__LineNumber__c = '0001.0001.0001', Quantity = 1, UnitPrice = 100);

		sObjList.add(ql3);

		insert sObjList;
		sObjList.clear();

		// Create Applied Promotion
		vlocity_cmt__QuoteAppliedPromotion__c quoteApp = new vlocity_cmt__QuoteAppliedPromotion__c(Name='Test Applied Promo', vlocity_cmt__Action__c='Add', vlocity_cmt__QuoteId__c=testQuote.Id, vlocity_cmt__PromotionId__c=promos[0].Id);
		insert quoteApp;

		// Create Promotion Affected Items
		vlocity_cmt__QuoteAppliedPromotionItem__c quoteAppPromoItem = new vlocity_cmt__QuoteAppliedPromotionItem__c(Name='OAPI1', vlocity_cmt__AppliedAction__c='Add', vlocity_cmt__MaxQuantity__c=5.0,
				vlocity_cmt__MinQuantity__c=1.0, vlocity_cmt__QuoteAppliedPromotionId__c=quoteApp.Id, vlocity_cmt__QuoteLineItemId__c=ql1.Id);
		sObjList.add(quoteAppPromoItem);

		vlocity_cmt__QuoteAppliedPromotionItem__c quoteAppPromoItem2 = new vlocity_cmt__QuoteAppliedPromotionItem__c(Name='OAPI2', vlocity_cmt__AppliedAction__c='Add', vlocity_cmt__MaxQuantity__c=5.0,
				vlocity_cmt__MinQuantity__c=1.0, vlocity_cmt__QuoteAppliedPromotionId__c=quoteApp.Id, vlocity_cmt__QuoteLineItemId__c=ql2.Id);
		sObjList.add(quoteAppPromoItem2);

		insert sObjList;
		sObjList.clear();

		// Create Price Adjustments
		vlocity_cmt__QuotePricingAdjustment__c quotePA1 = new vlocity_cmt__QuotePricingAdjustment__c(Name='OPA1', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__QuoteAppliedPromotionId__c = quoteApp.Id, vlocity_cmt__QuoteId__c=testQuote.Id, vlocity_cmt__QuoteItemId__c=ql2.Id, vlocity_cmt__PriceListEntryId__c=ple4.Id,
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__PromotionId__c=promos[0].Id, vlocity_cmt__Source__c='Promotion');
		sObjList.add(quotePA1);


		vlocity_cmt__QuotePricingAdjustment__c quotePA2 = new vlocity_cmt__QuotePricingAdjustment__c(Name='OPA2', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__QuoteId__c=testQuote.Id, vlocity_cmt__QuoteItemId__c=ql2.Id, vlocity_cmt__PriceListEntryId__c=ple4.Id,
				vlocity_cmt__pricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Offer');
		sObjList.add(quotePA2);


		vlocity_cmt__QuotePricingAdjustment__c quotePA3 = new vlocity_cmt__QuotePricingAdjustment__c(Name='OPA2', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-50.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__QuoteAppliedPromotionId__c = quoteApp.Id, vlocity_cmt__QuoteId__c=testQuote.Id, vlocity_cmt__QuoteItemId__c=ql3.Id, vlocity_cmt__PromotionId__c=promos[0].Id, vlocity_cmt__PriceListEntryId__c=ple4.Id,
				vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__PricingVariableId__c=oneTimeStdPriceVarDiscount.Id, vlocity_cmt__Source__c='Promotion');
		sObjList.add(quotePA3);

		vlocity_cmt__QuotePricingAdjustment__c quotePA4 = new vlocity_cmt__QuotePricingAdjustment__c(Name='OPA4', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-5.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__QuoteId__c=testQuote.Id, vlocity_cmt__QuoteItemId__c=ql3.Id, vlocity_cmt__PriceListEntryId__c=ple6.Id, vlocity_cmt__Source__c='Agent');
		sObjList.add(quotePA4);

		vlocity_cmt__QuotePricingAdjustment__c quotePA5 = new vlocity_cmt__QuotePricingAdjustment__c(Name='OPA5', vlocity_cmt__Action__c='Add', vlocity_cmt__AdjustmentValue__c=-5.0, vlocity_cmt__Amount__c=0.0,
				vlocity_cmt__QuoteId__c=testQuote.Id, vlocity_cmt__PriceListEntryId__c=ple6.Id, vlocity_cmt__PricingElementVersionId__c=pElem3.Id, vlocity_cmt__Source__c='Offer');
		sObjList.add(quotePA5);

		insert sObjList;
		sObjList.clear();

	}

	//Testing Quote objectType
	static private testmethod void testQuoteType(){
		setup();
		objectType = 'Quote';
		objectIds = new List<Id>();
		List<Quote> quoteIdList = [SELECT Id FROM Quote WHERE Name='Test Quote'];
		objectIds.add(quoteIdList[0].Id);

		List<SObject> priceAdjList = [SELECT Id FROM vlocity_cmt__QuotePricingAdjustment__c WHERE vlocity_cmt__QuoteId__c = :quoteIdList[0].Id];
		System.assert(priceAdjList != null && priceAdjList.size() == 5);

		Test.startTest();
		DeleteProductAdjustmentBatchJob batch = new DeleteProductAdjustmentBatchJob(objectType,objectIds);
		batchId = Database.executeBatch(batch);
		Test.stopTest();

		priceAdjList = [SELECT Id FROM vlocity_cmt__QuotePricingAdjustment__c WHERE vlocity_cmt__QuoteId__c = :quoteIdList[0].Id];
		System.assert(priceAdjList != null && priceAdjList.size() == 4);
	}

	//Testing Opportunity objectType
	static private testmethod void testOpportunityType(){
		setup();
		objectType = 'Opportunity';
		objectIds = new List<Id>();
		List<Opportunity> opportunityIdList = [SELECT Id FROM Opportunity WHERE Name='testOpp'];
		objectIds.add(opportunityIdList[0].Id);

		List<SObject> priceAdjList = [SELECT Id FROM vlocity_cmt__OpportunityPriceAdjustment__c WHERE vlocity_cmt__OpportunityId__c = :opportunityIdList[0].Id];
		System.assert(priceAdjList != null && priceAdjList.size() == 5);

		Test.startTest();
		DeleteProductAdjustmentBatchJob batch = new DeleteProductAdjustmentBatchJob(objectType,objectIds);
		batchId = Database.executeBatch(batch);
		Test.stopTest();

		priceAdjList = [SELECT Id FROM vlocity_cmt__OpportunityPriceAdjustment__c WHERE vlocity_cmt__OpportunityId__c = :opportunityIdList[0].Id];
		System.assert(priceAdjList != null && priceAdjList.size() == 4);
	}

	//Testing Order objectType
	static private testmethod void testOrderType(){
		setup();
		objectType = 'Order';
		objectIds = new List<Id>();
		List<Order> orderIdList = [SELECT Id FROM Order WHERE Name='Test Order'];
		objectIds.add(orderIdList[0].Id);
		List<SObject> priceAdjList = [SELECT Id FROM vlocity_cmt__OrderPriceAdjustment__c WHERE vlocity_cmt__OrderId__c = :orderIdList[0].Id];
		System.assert(priceAdjList != null && priceAdjList.size() == 5);

		Test.startTest();
		DeleteProductAdjustmentBatchJob batch = new DeleteProductAdjustmentBatchJob(objectType,objectIds);
		batchId = Database.executeBatch(batch);
		Test.stopTest();

		priceAdjList = [SELECT Id FROM vlocity_cmt__OrderPriceAdjustment__c WHERE vlocity_cmt__OrderId__c = :orderIdList[0].Id];
		System.assert(priceAdjList != null && priceAdjList.size() == 4);
	}

}