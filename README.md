

Three entry points:

- prepare/install.sh
    install Docker
    Any packages that add new groups used by install.sh or run.sh must be added here

- prepare/build.sh
    Checkout docker and private repo
    Build docker images

- run/run.sh
    will launch any run_*.sh shell scripts inside directory
    Ouput of each test suite should be put inside $HOME/output/
