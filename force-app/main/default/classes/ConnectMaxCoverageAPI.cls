@RestResource(urlMapping='/api/v1/coverageCheck/*')
global with sharing class ConnectMaxCoverageAPI {
    global class CoverageResponse {
        global Boolean success { get; set; }
        global String message { get; set; }
        global String cepConsulta { get; set; }
        global Boolean hasCoverage { get; set; }
        global String maxSpeed { get; set; }

        global CoverageResponse(Boolean success, String message, String cep, Boolean coverage, String speed) {
            this.success = success;
            this.message = message;
            this.cepConsulta = cep;
            this.hasCoverage = coverage;
            this.maxSpeed = speed;
        }
    }

    @HttpGet
    global static void checkCoverage() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        CoverageResponse responseBody;

        String cep = '';

        try {
            cep = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            List<Coverage_Area__c> coverageList = [ 
                SELECT Has_Fiber_Coverage__c, Max_Speed_Available__c 
                FROM Coverage_Area__c
                WHERE CEP__c = :cep
                LIMIT 1
            ];

            if(!coverageList.isEmpty()) {
                Coverage_Area__c area = coverageList[0];
                responseBody = new CoverageResponse(
                    true,
                    'Consulta realizada com sucesso',
                    cep,
                    area.Has_Fiber_Coverage__c,
                    area.Max_Speed_Available__c
                );

                res.statusCode = 200;
            } else {
                responseBody = new CoverageResponse(
                        true, 
                        'Região não atendida pela ConnectMax.', 
                        cep, 
                        false, 
                        null
                    );
                    res.statusCode = 200;
            }
        } catch (Exception e) {
            responseBody = new CoverageResponse(
                false,
                'Erro interno no servidor ' + e.getMessage(),
                cep,
                false,
                null
            );
            res.statusCode = 500;
        }

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseBody));
    }
}