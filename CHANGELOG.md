# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format located [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]

## [0.0.1] - 2018-04-02
### Breaking Changes
- Dropped `ruby 2.1` support (@yuri-zubov sponsored by Actility, https://www.actility.com)
- Added `rest-client` as a dependency which requires you to have a local c compiler present to install this plugin (@yuri-zubov sponsored by Actility, https://www.actility.com)
- bumped dependency of `sensu-plugin` to 2.x you can read about it [here](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#v200---2017-03-29) (@majormoses)
- dropped ruby 2.0 support (@majormoses)

### Security
- updated `yard` dependency to `~> 0.9.11` per: https://nvd.nist.gov/vuln/detail/CVE-2017-17042 which closes attacks against a yard server loading arbitrary files (@majormoses)

### Added
- Added health-check for gitlab (@yuri-zubov sponsored by Actility, https://www.actility.com)
- Added basic metrics from gitlab (@yuri-zubov sponsored by Actility, https://www.actility.com)
- Basic Skel to be used to make new plugin repo setup easier.
- PR template
- Rubocop config
- basic testing setup

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-skel/compare/0.0.1...HEAD
[0.0.1]: https://github.com/sensu-plugins/sensu-plugins-skel/compare/0b2d68b64a3d100c10da5e4cfce42206b9f22250...0.0.1
