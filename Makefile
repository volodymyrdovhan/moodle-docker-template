#!/usr/bin/make

## export moodleroot=moodle.local - required to run scripts in moodle.local folder
## export dockerfile='-f docker-compose.yml -f docker-compose.mailhog.yml' - php 8.1 with MySQL
## export dockerfile='-f docker-compose.yml -f docker-compose.php80.yml -f docker-compose.cli.php80.yml -f docker-compose.dbpostgre13.yml -f docker-compose.mailhog.yml -f docker-compose.adminer.yml'

DIRROOT = /var/www/html/${moodleroot}
MOODLEDATADIR = /var/www/html/moodledata/${moodleroot}
PHPUNITDATADIR = /var/www/html/phpunitdata/${moodleroot}
DOCKERFILE = ${dockerfile}

## use static DIRROOT if you are using only one host
#DIRROOT = /var/www/html/

cli_service=moodle_php_cli
run_in_cli=docker-compose $(DOCKERFILE) run -w "$(DIRROOT)" --rm $(cli_service)
exec_in_cli=docker-compose exec $(cli_service) /bin/sh -c

install: files_permissions
	 docker-compose $(DOCKERFILE) build

## docker
docker_up:
	docker-compose $(DOCKERFILE) up -d

docker_down:
	docker-compose $(DOCKERFILE) down

docker_build:
	docker-compose $(DOCKERFILE) build --no-cache --parallel --force-rm --compress

# preferable to use NVM with multiple node versions
#amd_build:
#	$(run_in_cli) grunt amd --root=$(pluginpath)/amd --force
#	$(run_in_cli) grunt amd --root=local/intellidata/amd --force

run_cron:
	$(run_in_cli) php admin/cli/cron.php

## unit tests
init_tests:
	$(run_in_cli) /bin/sh -c "mkdir -p ${PHPUNITDATADIR} && chmod -R 777 ${PHPUNITDATADIR}"
	$(run_in_cli) php admin/tool/phpunit/cli/init.php

## setup utils
init_utils:
	$(run_in_cli) php admin/tool/phpunit/cli/util.php --buildcomponentconfigs

## unit tests coverage
## example: make testsuite=tool_dataprivacy_testsuite run_testsuite_coverage
run_testsuite_coverage:
	$(run_in_cli) phpdbg -qrr vendor/bin/phpunit --coverage-text --testsuite $(testsuite)

## run testsuite
## example: make testsuite=tool_dataprivacy_testsuite run_testsuite
run_testsuite:
	$(run_in_cli) vendor/bin/phpunit --coverage-text --testsuite $(testsuite)

## run single test file
## example: make testsuite=data_registry_test run_test
run_test:
	$(run_in_cli) vendor/bin/phpunit --filter $(testcase)

run_moodle_tests:
	$(run_in_cli) vendor/bin/phpunit --fail-on-risky --disallow-test-output --testsuite tool_dataprivacy_testsuite --filter metadata_registry_test
	$(run_in_cli) vendor/bin/phpunit --fail-on-risky --disallow-test-output --testsuite core_testsuite --filter test_all_external_info
	$(run_in_cli) vendor/bin/phpunit --fail-on-risky --disallow-test-output --testsuite core_privacy_testsuite --filter provider_test

## install node
## note: required for CI
node_install:
	$(run_in_cli) npm install --save-dev grunt grunt-contrib-less grunt-contrib-watch grunt-load-gruntfile


## ci configuration
## note: the installation may throw an error related to permissions but ci will be configured
init_ci:
	$(run_in_cli) /bin/sh -c "mkdir -p ${MOODLEDATADIR} && chmod -R 777 ${MOODLEDATADIR}"
	$(run_in_cli) /bin/sh -c "if [ -d ./ci ]; then rm -rf ./ci; fi && composer create-project -n --no-dev --prefer-dist moodlehq/moodle-plugin-ci ci ^4 && chmod -R 0777 ./ci"

## run ci
## example: make pluginpath=admin/tool/dataprivacy run_ci_phplint
run_ci_phplint:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci phplint $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_phpcpd
run_ci_phpcpd:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci phpcpd $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_phpmd
run_ci_phpmd:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci phpmd $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_codechecker
run_ci_codechecker:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci codechecker $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_phpdoc
run_ci_phpdoc:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci phpdoc $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_savepoints
run_ci_savepoints:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci savepoints $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_mustache
## note: currently not working
#run_ci_mustache:
#	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci mustache $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_grunt
run_ci_grunt:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci grunt $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_validate
run_ci_validate:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci validate $(pluginpath)"

## example: make pluginpath=admin/tool/dataprivacy run_ci_phpunit
run_ci_phpunit:
	$(run_in_cli) /bin/sh -c "ci/bin/moodle-plugin-ci phpunit --coverage-clover $(pluginpath)"

## example: make run_ci_dbschema
run_ci_dbschema:
	make path=admin/cli/check_database_schema.php run_php_script


# run plugin ci
## example: make pluginpath=admin/tool/dataprivacy run_plugin_ci
## note: the process may throw an error and stop next commands execution
run_plugin_ci:
	make pluginpath=$(pluginpath) run_ci_phplint
	make pluginpath=$(pluginpath) run_ci_phpcpd
	make pluginpath=$(pluginpath) run_ci_phpmd
	make pluginpath=$(pluginpath) run_ci_codechecker
	make pluginpath=$(pluginpath) run_ci_phpdoc
	make pluginpath=$(pluginpath) run_ci_savepoints
#	make pluginpath=$(pluginpath) run_ci_mustache
	make pluginpath=$(pluginpath) run_ci_grunt
	make pluginpath=$(pluginpath) run_ci_validate
	make pluginpath=$(pluginpath) run_ci_phpunit
	make run_ci_dbschema

## change files permissions
files_permissions:
	sudo chmod -R 777 ./database/* \
	                  ./moodledata/*

## run php script in container
run_php_script:
	$(run_in_cli) /bin/sh -c "php $(path)"

## run php script in container
run_cli_sh:
	$(run_in_cli) /bin/sh -c "$(script)"