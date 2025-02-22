import json
import os
import requests

from dotenv import load_dotenv
from jinja2 import Environment, FileSystemLoader

load_dotenv()

# Get all droplets from DigitalOcean API

print('Fetching droplets... ', end='', flush=True)

url = 'https://api.digitalocean.com'
endpoint = f'{url}/v2/droplets'

token = os.getenv('DIGITALOCEAN_TOKEN')

headers = {
    'Authorization': f'Bearer {token}'
}

response = requests.get(endpoint, params={'tag_name': 'noalexan'}, headers=headers)

if not response.status_code == 200:
    print(f"Error: {response.status_code}")
    print(response.text)
else:
    data = response.json()
    for droplet in data['droplets']:
        droplet['networks']['v4'] = [network for network in droplet['networks']['v4'] if network['type'] == 'public'][:1]

print('done')

# Create inventory.yaml from templates/inventory.template

print('Generating inventory.yaml... ', end='', flush=True)

environment = Environment(loader=FileSystemLoader("templates/"))

template = environment.get_template("inventory.j2")
content = template.render(
    hosts=[
        {
            "name": "DigitalOcean",
            **data
        }
    ],
    ansible_user="root"
)

with open("inventory.yml", "w+") as file:
    file.write(content)

print('done')
