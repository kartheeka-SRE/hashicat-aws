#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  index=uwcrdtsvc splunk_server_group=TAWS logGroup="/aws/ecs/uwcrdtsvc-ecs-acpt/uwcrdtsvc-credit-retrieval-service"  ALL_CRAS_DURATION_MS
    "cwmessage.springAppName"="creditRetrieval" | search cwmessage.x-fnma-correlation-id=UWT3DEA2EEBE38A47118396FF4152306141  
    | stats values(cwmessage.ALL_CRAS_DURATION_MS) AS CRA
      
| appendcols [search index=uwloanapp splunk_server_group=TAWS logGroup="/aws/ecs/uwloanapp-ecs-acpt/uwloanapp-uw-entry-service-service" 
("cwmessage.SERVICE_STATUS"="SUCCESS") "cwmessage.MSG_TYPE"="SERVICE_RESPONSE" "cwmessage.REQUEST_TYPE"="GetCreditReport" 
"cwmessage.HTTP_CODE"="200" "cwmessage.springAppName"="UW-entry-service" | search cwmessage.x_fnma_correlation_id=UWT3DEA2EEBE38A47118396FF4152306141 OR cwmessage.x-fnma-correlation-id=UWT3DEA2EEBE38A47118396FF4152306141   
| stats values(cwmessage.SERVICE_DURATION_MS) as E2E_RoundTrip ]

| appendcols [search index=uwcrdtsvc splunk_server_group=TAWS logGroup="/aws/ecs/uwcrdtsvc-ecs-acpt/uwcrdtsvc-credit-retrieval-service" 
("cwmessage.SERVICE_STATUS"="SUCCESS") "cwmessage.MSG_TYPE"="SERVICE_RESPONSE"  "cwmessage.springAppName"="creditRetrieval"  "cwmessage.RESPONSE_TYPE"=XIS_CREDIT_ONLY | search cwmessage.x-fnma-correlation-id=UWT3DEA2EEBE38A47118396FF4152306141  
| stats values(cwmessage.SERVICE_DURATION_MS) AS CrdRtrvl_RT ] 

| eval CrdRtrvl  = CrdRtrvl_RT - CRA
| eval EntryService  = E2E_RoundTrip - CrdRtrvl_RT
| table CRA, CrdRtrvl, EntryService, E2E_RoundTrip

  <center><img src="http://${PLACEHOLDER}/${WIDTH}/${HEIGHT}"></img></center>
  <center><h2>Meow World!</h2></center>
  Welcome to ${PREFIX}'s app. Replace this text with your own.
  <!-- END -->

  </div>
  </body>
</html>
EOM

echo "Script complete."
