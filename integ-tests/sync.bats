setup() {
    load '/usr/lib/bats/bats-support/load'
    load '/usr/lib/bats/bats-assert/load'
    cd /work/sync
    rm -rf project
    mkdir project
    cd project
}

@test 'sync: default' {
    run rye init
    assert_success

    run rye add cowsay
    assert_success
    assert_output --partial 'Added cowsay>='

    run cat pyproject.toml
    assert_line --regexp '"cowsay>=.*",'

    assert [ ! -f requirements.lock ]
    assert [ ! -f requirements-dev.lock ]
    assert [ ! -d .venv ]

    run rye sync
    assert_success
    assert_line 'Initializing new virtualenv in /work/sync/project/.venv'
    assert_line 'Generating production lockfile: /work/sync/project/requirements.lock'
    assert_line 'Generating dev lockfile: /work/sync/project/requirements-dev.lock'
    assert_output --partial 'Collecting cowsay=='
    assert_output --partial 'Successfully installed cowsay-'
    assert [ -f requirements.lock ]
    assert [ -f requirements-dev.lock ]
    assert_equal "$(cat requirements.lock)" "$(cat requirements-dev.lock)"
    assert [ -d .venv ]
    assert [ -d .venv/lib/python3.11/site-packages/cowsay ]

    run cat requirements.lock
    assert_line --partial 'cowsay=='

    run cat requirements-dev.lock
    assert_line --partial 'cowsay=='

    run rye run python -c "import cowsay; cowsay.cow(\"I'm synced\")"
    assert_success
    assert_output --partial "| I'm synced |"

    run rye run cowsay "I'm synced"
    assert_success
    assert_output --partial "| I'm synced |"
}

@test 'sync: dev' {
    run rye init
    assert_success

    run rye add --dev pytest
    assert_success
    assert_output --partial 'Added pytest>='

    run rye sync
    assert_success

    assert_not_equal "$(cat requirements.lock)" "$(cat requirements-dev.lock)"

    run cat requirements.lock
    refute_line --partial 'pytest=='

    run cat requirements-dev.lock
    assert_line --partial 'pytest=='

    cp ../test_pytest.py ./
    run rye run pytest -v test_pytest.py
    assert_failure 1
    assert_line --partial 'test_pytest.py::test_ok PASSED'
    assert_line --partial 'test_pytest.py::test_fail FAILED'
}
