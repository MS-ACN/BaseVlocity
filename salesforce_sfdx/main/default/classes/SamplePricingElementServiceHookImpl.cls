/**
 * This class is used as a sample hook implementation to the PricingElementServiceImplementation.
 * To use this class, create a PricingElementServiceImplementationH interface under All Tabs > Interface Implementations
 * and set SamplePricingElementServiceHookImpl as the default and active implementation class. The invokeMethod of this
 * hook class will be called both before and after the invokeMethod of the PricingElementServiceImplementation.
 * The methods will be suffixed with PreInvoke and PostInvoke respectively to indicate whether it is being called before
 * or after the PricingElementServiceImplementation method.
 */
global with sharing class SamplePricingElementServiceHookImpl implements vlocity_cmt.VlocityOpenInterface{

    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)  {

        try
        {
            System.debug('--- SamplePricingElementServiceHookImpl methodName: ' + methodName);


            if (methodName.equalsIgnoreCase('priceLineItems.PreInvoke'))
            {
                priceLineItemsPreInvoke(input, output,options);
            }

            return true;
        }
        catch (Exception ex)
        {
            System.debug('--- Exception: ' + ex.getMessage());
            System.debug('--- Stack Trace: ' + ex.getStackTraceString());
            throw ex;
        }
    }


    private void priceLineItemsPreInvoke(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {

        SObject parent = (SObject)input.get('parent');
        List<SObject> itemList = (List<SObject>)input.get('itemList');

        //System.debug('--- priceLineItemsPreInvoke parent: ' + JSON.serialize(parent));
        //System.debug('--- priceLineItemsPreInvoke itemList: ' + JSON.serialize(itemList));

        String cartAction = (String)input.get('cartAction');

        // Only execute when cartAction is adding items to the cart
        if (cartAction != 'AddCartItem' && cartAction != 'AddCartPromotionItem') return;

        // collect the items by product names we want to set external prices for
        Set<String> prodNames = new Set<String>{'Test Prod 2'};
        Map<String, List<SObject>> productNameToItemObjs = new Map<String, List<SObject>>();
        for (SObject item : itemList)
        {
            String prodName = (String)item.getSObject('PricebookEntry').getSObject('Product2').get('Name');
            if (prodNames.contains(prodName))
            {
                List<SObject> itemObjList = productNameToItemObjs.get(prodName);
                if (itemObjList == null)
                {
                    itemObjList = new List<SObject>();
                    productNameToItemObjs.put(prodName, itemObjList);
                }
                itemObjList.add(item);
            }
        }

        // simulate external prices
        Type t = Type.forName('vlocity_cmt.SetCartItemExternalPriceService');
        if (t != null)
        {
            vlocity_cmt.VlocityOpenInterface externalPriceService = (vlocity_cmt.VlocityOpenInterface)t.newInstance();
            Map<String, Object> externalPriceServiceInput = new Map<String, Object>();
            Map<String, Object> externalPriceServiceOutput = new Map<String, Object>();
            Map<String, Object> externalPriceServiceOptions = new Map<String, Object>();

            Map<String, Object> itemFields = new Map<String, Object>();

            for (String productName : productNameToItemObjs.keySet())
            {
                List<SObject> itemObjList = productNameToItemObjs.get(productName);
                if (itemObjList != null)
                {
                    for (SObject itemObj : itemObjList)
                    {
                        Map<String, Object> itemFieldDetails = new Map<String, Object>();
                        Map<String, Object> fieldVals = new Map<String, Object>();
                        fieldVals.put('value', 5.55);
                        fieldVals.put('detail', 'External price from matrix. Reference num 123.');
                        itemFieldDetails.put('vlocity_cmt__RecurringCharge__c', fieldVals);

                        fieldVals = new Map<String, Object>();
                        fieldVals.put('value', 999.99);
                        fieldVals.put('detail', 'External price from matrix. Reference num 456.');

                        itemFieldDetails.put('vlocity_cmt__OneTimeCharge__c', fieldVals);
                        itemFields.put(String.valueOf(itemObj.Id), itemFieldDetails);
                    }
                }
            }

            if (!itemFields.isEmpty())
            {
                externalPriceServiceInput.put('parent', parent);
                externalPriceServiceInput.put('itemList', itemList);
                externalPriceServiceInput.put('itemFieldsInfo', itemFields);

                //System.debug('--- setExternalPrices externalPriceServiceInput: ' + JSON.serialize(externalPriceServiceInput));
                externalPriceService.invokeMethod('setItemPrices', externalPriceServiceInput, externalPriceServiceOutput, externalPriceServiceOptions);
            }
        }

    }
}