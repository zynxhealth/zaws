# Status

Beta software - Expect frequent releases of 0.0.* versions. Minor Bugs are being removed. You can submit [issues](https://github.com/zynxhealth/zaws/issues) as well and they will be looked into.

[![Build Status](https://travis-ci.org/zynxhealth/zaws.svg?branch=master)](https://travis-ci.org/zynxhealth/zaws)     [![Coverage Status](https://coveralls.io/repos/zynxhealth/zaws/badge.png?branch=master)](https://coveralls.io/r/zynxhealth/zaws?branch=master) [![Gem Version](https://badge.fury.io/rb/zaws.svg)](http://badge.fury.io/rb/zaws)

* For some reason the Coverage is flip floppping between 99% and mid 80%s, this looks like an issue with picking up some results. The 99% value is more accurate.

# zaws

Zynx AWS Automation Tool

* [Start using "zaws" today](https://github.com/zynxhealth/zaws/wiki/02.-Start-Using-%22zaws%22). This will give you the first steps.
* [Authorization Delegated to AWS CLI](https://github.com/zynxhealth/zaws/wiki/Authorization-Done-by-AWS-CLI)
* The [design](https://github.com/zynxhealth/zaws/wiki/04.-Design) of the application is uniform and can be understood with a little effort.
* The [testing strategy](https://github.com/zynxhealth/zaws/wiki/05.-Testing) has elements of BDD using cucumber and TDD using Rspec.
* [Enhancement requests and issues](https://github.com/zynxhealth/zaws/issues) are tracked here on github. Please feel free to make requests, submit issue tickets, or submit [pull requests](https://github.com/zynxhealth/zaws/pulls).
* The [reference](https://github.com/zynxhealth/zaws/wiki/06.-References-(eg-Books,-...)) section contains lists of sources that were used in this project.

# Development

1. Fork repostiory.
2. Clone to workstation.
3. Run "bundle install" to get all development dependencies.
4. Modfiy code.
5. Run spec tests with "bundle exec rspec spec"
6. Run feature tests with "bundle exec cucumber feature"
7. Push to forked repository.
8. Create pull request.
9. Have a good day! We''ll get back to you ASAP.

