/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ConnectMaxCoverageAPI_Test {

    @TestSetup
    static void makeData(){
        Coverage_Area__c testArea = new Coverage_Area__c(
            CEP__c = '12345678',
            Has_Fiber_Coverage__c = true,
            Max_Speed_Available__c = '600 Mbps'
        );
        insert testArea;
    }

    @isTest
    static void CoverageAPIhasCoverageTest() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        String cep = '12345678';
        req.requestURI = '/services/apexrest/api/v1/coverageCheck/' + cep;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ConnectMaxCoverageAPI.checkCoverage();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'O status code deveria ser 200');
        
        String jsonResponse = res.responseBody.toString();
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        System.assertEquals(true, result.get('success'), 'O success deveria ser true');
        System.assertEquals(true, result.get('hasCoverage'), 'Deveria ter cobertura para este CEP');
        System.assertEquals('600 Mbps', result.get('maxSpeed'), 'A velocidade deveria ser 600 Mbps');
    }

    @isTest
    static void CoverageAPIhasNoCoverageTest() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String cep = '00000000';
        req.requestURI = '/services/apexrest/api/v1/coverageCheck/' + cep;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ConnectMaxCoverageAPI.checkCoverage();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'O status code deveria ser 200 mesmo sem cobertura (a API não falhou, só não achou o cpf)');
        
        String jsonResponse = res.responseBody.toString();
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        System.assertEquals(true, result.get('success'), 'A chamada da API teve sucesso');
        System.assertEquals(false, result.get('hasCoverage'), 'Não deveria ter cobertura para este CEP');
        System.assertEquals(null, result.get('maxSpeed'), 'A velocidade deveria ser nula');
    }

    @isTest
    static void CoverageAPIServerErrorTest() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = null; 
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ConnectMaxCoverageAPI.checkCoverage();
        Test.stopTest();

        System.assertEquals(500, res.statusCode, 'O status code deveria ser 500 devido ao requestURI ser nulo');
        
        String jsonResponse = res.responseBody.toString();
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        System.assertEquals(false, result.get('success'), 'A requisição deveria ter falhado (success = false)');
        System.assertEquals(false, result.get('hasCoverage'), 'A cobertura deve ser false em caso de erro');
    }
}