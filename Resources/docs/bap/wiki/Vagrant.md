BAP ships a vagrant file, that will provision Ubuntu Trusty with the latest BAP release. So to get BAP up and running in a few minutes just do the following

    git clone https://github.com/BinaryAnalysisPlatform/bap.git
    cd bap/vagrant/trusty64
    vagrant up
    vagrant ssh

If running on Windows, add
`config.vm.synced_folder ".", "/vagrant", type: "virtualbox"`
to the Vagrantfile to avoid [this](http://stackoverflow.com/questions/34176041/vagrant-with-virtualbox-on-windows10-rsync-could-not-be-found-on-your-path) error.


    