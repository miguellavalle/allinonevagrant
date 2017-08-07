from keystoneclient.auth import token_endpoint
from keystoneclient import session
from placementclient import client


session = session.Session()
my_token = '26800d75c2ae451d8af1ff4f020d6743'
url = 'http://192.168.33.12:8778/'
auth = token_endpoint.Token(url, my_token)
my_client = client.Client('1', session=session, auth=auth)
resource_provider = {'name': 'subnet-d08efb3d-ba36-42ca-ac2a-850b23ad8d10',
                     'uuid': 'd08efb3d-ba36-42ca-ac2a-850b23ad8d10'}
inventory = {'total': 256, 'reserved': 5, 'min_unit': 1, 'max_unit': 1,
             'step_size': 1, 'allocation_ratio': 1.0,
             'resource_class': 'IPV4_ADDRESS'}
aggregates = ['21d7c4aa-d0b6-41b1-8513-12a1eac17c0c',
              'b455ae1f-5f4e-4b19-9384-4989aff5fee9']
import pdb
pdb.set_trace()
my_client.resource_providers.list()
