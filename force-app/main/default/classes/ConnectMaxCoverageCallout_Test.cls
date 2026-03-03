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
private class ConnectMaxCoverageCallout_Test {

    private class ConnectMaxCoverageMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public ConnectMaxCoverageMock(Integer code, String body) {
            this.statusCode = code;
            this.responseBody = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.responseBody);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }

    @isTest
    static void testCalloutSuccessWithCoverage() {
        String mockJsonResponse = '{"success":true,"message":"Consulta realizada com sucesso.","cepConsulta":"12345678","hasCoverage":true,"maxSpeed":"600 Mbps"}';

        Test.setMock(HttpCalloutMock.class, new ConnectMaxCoverageMock(200, mockJsonResponse));

        ConnectMaxCoverageCallout.FlowInput input = new ConnectMaxCoverageCallout.FlowInput();
        input.cep = '12345678';
        List<ConnectMaxCoverageCallout.FlowInput> inputListForFlow = new List<ConnectMaxCoverageCallout.FlowInput>{ input };

        Test.startTest();
        List<ConnectMaxCoverageCallout.FlowOutput> results = ConnectMaxCoverageCallout.checkCoverageFromFlow(inputListForFlow);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Deveria retornar 1 resultado na lista');
        System.assertEquals(true, results[0].success, 'A chamada deveria ser marcada como sucesso');
        System.assertEquals(true, results[0].hasCoverage, 'Deveria identificar que tem cobertura');
        System.assertEquals('600 Mbps', results[0].maxSpeed, 'A velocidade mapeada deveria ser 600 Mbps');
    }

    @isTest
    static void testCalloutApiError() {
        String mockJsonResponse = '{"success":false,"message":"Erro interno no servidor","cepConsulta":"000","hasCoverage":false,"maxSpeed":null}';

        Test.setMock(HttpCalloutMock.class, new ConnectMaxCoverageMock(500, mockJsonResponse));

        ConnectMaxCoverageCallout.FlowInput input = new ConnectMaxCoverageCallout.FlowInput();
        input.cep = '000';

        Test.startTest();
        List<ConnectMaxCoverageCallout.FlowOutput> results = ConnectMaxCoverageCallout.checkCoverageFromFlow(new List<ConnectMaxCoverageCallout.FlowInput>{ input });
        Test.stopTest();
        
        System.assertEquals(false, results[0].success, 'O FlowOutput deveria marcar false para o sucesso da API');
        System.assertEquals(false, results[0].hasCoverage, 'Não deveria haver cobertura listada em caso de erro');
        System.assert(results[0].message.contains('Status Code 500'), 'A mensagem deveria refletir o erro 500 do HTTP');
    }
}