setup() {
    load '/usr/lib/bats/bats-support/load'
    load '/usr/lib/bats/bats-assert/load'
    cd /work/version
    rm -rf project
    mkdir project
    cd project
}

@test 'static version' {
    run rye init
    assert_success

    run rye version
    assert_success
    assert_output '0.1.0'

    run rye version '0.2.0'
    assert_success

    run rye version
    assert_success
    assert_output '0.2.0'
}

@test 'dynamic version' {
    run rye init
    assert_success

    sed -i '/^version = /d' pyproject.toml
    sed -i '/\[project\]/a dynamic = [ "version" ]' pyproject.toml
    sed -i '$a[tool.hatch.version]\npath = "src/project/__init__.py"' pyproject.toml

    sed -i '1 i\__version__ = "0.5.1"\n\n' src/project/__init__.py

    run rye version
    assert_success
    assert_output '0.5.1'

    run cat pyproject.toml
    refute_output --partial 'version ='

    run rye version '0.2.0'
    assert_failure 1
    assert_output 'error: unsupported set dynamic version'
}
