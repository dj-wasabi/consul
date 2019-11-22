
import requests
import base64
import json


def test_socker(host):
    assert host.socket('tcp://:::8500').is_listening
    assert host.socket('tcp://:::8302').is_listening
    assert host.socket('udp://:::8302').is_listening
    assert host.socket('tcp://:::8301').is_listening
    assert host.socket('udp://:::8301').is_listening
    assert host.socket('tcp://:::8300').is_listening
    assert host.socket('udp://:::53').is_listening


def test_config_file(host):
    config_file = host.file("/consul/config.json")
    assert config_file.user == "consul"
    assert config_file.group == "root"
    assert config_file.mode == 0o644
    assert config_file.contains('"data_dir": "/consul/data"')


def test_add_key_to_consul():
    data = requests.put('http://localhost:8500/v1/kv/foo', data="This is an test.")
    assert data.status_code == 200


def test_get_key_from_consul():
    data = requests.get('http://localhost:8500/v1/kv/foo')
    json_data = data.json()
    value = base64.b64decode(json_data[0]['Value'])
    assert value == "This is an test."
