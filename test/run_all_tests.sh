#!/bin/sh

ERROR=0;
function run {
    echo
    echo "==============================================="
    echo $1
    echo "==============================================="
    echo
    shift
    $@
    if [ $? -eq 0 ]; then return; fi
    ERROR=1
}

##### INSTALL DEPS #####
cd perl
run "Install main deps" cpanm --installdeps --notest --with-recommends .

cd ../perl-netcurl
run "Install NetCurl deps" cpanm --installdeps --notest --with-recommends .

cd ../perl-async
run "Install Async deps" cpanm --installdeps --notest --with-recommends .
cd ..
########################

export ES=localhost:9200

###### RUN TESTS #######
cd perl
run "Sync Perl core tests" \
    prove -l t/*/*.t
cd ..

run 'YAML: Sync Perl with LWP' \
    ./test/run_yaml_tests.pl

run 'YAML: Sync Perl with NetCurl' \
    ./test/run_yaml_tests.pl \
    --cxn NetCurl
#########################

exit $ERROR
