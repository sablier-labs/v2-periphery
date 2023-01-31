# Sablier V2 Periphery [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![Styled with Prettier][prettier-badge]][prettier] [![License: LGPL v3][license-badge]][license]

[gha]: https://github.com/sablierhq/v2-core/actions
[gha-badge]: https://github.com/sablierhq/v2-core/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[prettier]: https://prettier.io
[prettier-badge]: https://img.shields.io/badge/Code_Style-Prettier-ff69b4.svg
[license]: https://www.gnu.org/licenses/lgpl-3.0
[license-badge]: https://img.shields.io/badge/License-LGPL_v3-blue.svg

This repository contains the periphery smart contracts for the Sablier V2 Protocol.
For the core contracts, see the [sablier-v2-core](https://github.com/sablierhq/v2-core)
repository.

## Install

### Foundry

First, run the install step:

```sh
forge install --no-commit sablierhq/v2-periphery
```

Then, add the following line to your `remappings.txt` file:

```text
@sablier/v2-periphery/=lib/v2-periphery/src/
```
