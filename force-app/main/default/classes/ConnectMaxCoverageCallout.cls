public with sharing class ConnectMaxCoverageCallout {
    
    public class FlowInput {
        @InvocableVariable(label='CEP para consulta' description='O CEP que será consultado na API' required=true)
        public String cep;
    }

    public class FlowOutput {
        @InvocableVariable(label='Sucesso na Chamada')
        public Boolean success;

        @InvocableVariable(label='Possui Cobertura')
        public Boolean hasCoverage;

        @InvocableVariable(label='Velocidade Máxima')
        public String maxSpeed;

        @InvocableVariable(label='Mensagem de Retorno')
        public String message;
    }

    @InvocableMethod(label='Consultar Cobertura ConnectMax' description='Faz a chamada para a API interna de verificação de viabilidade técnica.')
    public static List<FlowOutput> checkCoverageFromFlow(List<FlowInput> inputs) {
        List<FlowOutput> results = new List<FlowOutput>();

        for(FlowInput input : inputs) {
            results.add(makeCallout(input.cep));
        }

        return results;
    }

    public static FlowOutPut makeCallOut(String cep) {
        FlowOutput output = new FlowOutput();

        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            request.setEndpoint('callout:ConnectMax_API_Credential/services/apexrest/api/v1/coverageCheck/' + cep);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = http.send(request);

            if(response.getStatusCode() == 200) {
                Map<String,Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                output.success = (Boolean) jsonResponse.get('success');
                output.hasCoverage = (Boolean) jsonResponse.get('hasCoverage');
                output.maxSpeed = (String) jsonResponse.get('maxSpeed');
                output.message = (String) jsonResponse.get('message');
            } else {
                output.success = false;
                output.hasCoverage = false;
                output.message = 'Erro na API: Status Code ' + response.getStatusCode();
            }
        } catch (Exception e) {
            output.success = false;
            output.hasCoverage = false;
            output.message = 'Erro de Callout: ' + e.getMessage();
        }
        
        return output;
    }
}