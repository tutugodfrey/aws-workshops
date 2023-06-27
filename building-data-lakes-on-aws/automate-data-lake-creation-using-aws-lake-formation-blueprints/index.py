import boto3
import json
import urllib3
http = urllib3.PoolManager()
def lambda_handler(event, context):
    athena = boto3.client('athena')
    work_group = event['ResourceProperties']['WorkGroup'];
    query_location = event['ResourceProperties']['QueryLocation'];
    config_updates = {'EnforceWorkGroupConfiguration':True,'ResultConfigurationUpdates':{'OutputLocation':query_location}}
    athena.update_work_group(WorkGroup=work_group, ConfigurationUpdates=config_updates)
    responseValue = int(event['ResourceProperties']['Input']) * 5
    responseData = {}
    responseData['Data'] = responseValue
    send_response(event, context, "SUCCESS", "Work group updated successfully", responseData)

def send_response(event, context, status, reason, data):
    body = json.dumps({
        "Status": status,
        "Reason": reason,
        "PhysicalResourceId": context.log_stream_name,
        "StackId": event.get("StackId"),
        "RequestId": event.get("RequestId"),
        "LogicalResourceId": event.get("LogicalResourceId"),
        "NoEcho": False,
        "Data": data
    })
    http.request(
        "PUT",
        event.get("ResponseURL"),
        body=body,
        headers={
            "Content-Type": "",
            "Content-Length": str(len(body))
        }
    )
