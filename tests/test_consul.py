
def test_socker(Socket):
    assert Socket('tcp://:::8500').is_listening
    assert Socket('tcp://:::8400').is_listening
    assert Socket('tcp://:::8302').is_listening
    assert Socket('udp://:::8302').is_listening
    assert Socket('tcp://:::8301').is_listening
    assert Socket('udp://:::8301').is_listening
    assert Socket('tcp://:::8300').is_listening
    assert Socket('udp://:::53').is_listening


def test_config_file(File):
    config_file = File("/consul/config.json")
    assert config_file.user == "consul"
    assert config_file.group == "root"
    assert config_file.mode == 0o644
    assert config_file.contains('"data_dir": "/consul/data"')
    assert config_file.contains('"ui_dir": "/consul/ui",')

