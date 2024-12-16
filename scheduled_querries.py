from google.cloud import bigquery_datatransfer

# Initialize the client
client = bigquery_datatransfer.DataTransferServiceClient()

# Specify the parent project
project_id = "dwoperation"
parent = f"projects/dwoperation/locations/-"

# List all scheduled queries
transfers = client.list_transfer_configs(parent=parent)
for transfer in transfers:
    print(f"Scheduled Query: {transfer.display_name}")
    print(f"Query: {transfer.params.get('query')}")
    print(f"Schedule: {transfer.schedule}")
