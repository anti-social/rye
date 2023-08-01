setup() {
    load '/usr/lib/bats/bats-support/load'
    load '/usr/lib/bats/bats-assert/load'
    cd /work/init
    rm -rf project
    mkdir project
    cd project
}

@test 'usage' {
    run rye
    assert_failure 2
    assert_line 'Usage: rye [COMMAND]'
}

@test 'init: default' {
    run rye init
    assert_success
    assert_line 'success: Initialized project in /work/init/project/.'
    assert [ -f .python-version ]
    assert [ -f README.md ]

    run cat pyproject.toml
    assert_line 'name = "project"'
    assert_line 'requires-python = ">= 3.8"'
    assert_line 'readme = "README.md"'
    assert_line 'build-backend = "hatchling.build"'

    run rye init
    assert_failure 1
    assert_output 'error: pyproject.toml already exists'
}

@test 'init: name' {
    run rye init --name my-project
    assert_success

    run cat pyproject.toml
    assert_line 'name = "my-project"'
}

@test 'init: do not pin python version' {
    run rye init --no-pin
    assert_success
    assert [ ! -f .python-version ]
}

@test 'init: min python version' {
    run rye init --min-py 3.10
    assert_success

    run cat pyproject.toml
    assert_line 'requires-python = ">= 3.10"'
}

@test 'init: python version for virtualenv' {
    run rye init --py 3.10.10
    assert_success
    assert [ -f .python-version ]

    run cat pyproject.toml
    assert_line 'requires-python = ">= 3.8"'

    run cat .python-version
    assert_output '3.10.10'
}

@test 'init: no readme' {
    run rye init --no-readme
    assert_success
    assert [ ! -f README.md ]

    run cat pyproject.toml
    refute_line 'readme = "README.md"'
}

@test 'init: setuptools' {
    run rye init --build-system setuptools
    assert_success

    run cat pyproject.toml
    assert_line 'build-backend = "setuptools.build_meta"'
}
