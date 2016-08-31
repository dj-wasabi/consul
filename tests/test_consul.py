
def test_socker(Socket):
    assert Socket('tcp://:::8500').is_listening


def test_config_file(File):
    config_file = File("/consul/config/config.json")
    assert config_file.user == "root"
    assert config_file.group == "root"
    assert config_file.mode == 0o644
    assert config_file.contains('"data_dir": "/consul/data"')


