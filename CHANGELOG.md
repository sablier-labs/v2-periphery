# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org).

[1.1.0]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/sablier-labs/v2-periphery/releases/tag/v1.0.0

## [1.1.0] - 2023-09-28

### Changed

- **Breaking**: Change `permit2Params` to `transferData`, which has type `bytes`
  ([#161](https://github.com/sablier-labs/v2-periphery/pull/161))
- Bump V2 Core ([#191](https://github.com/sablier-labs/v2-periphery/pull/191))
- Install `permit2` depencency from Uniswap repository ([#198](https://github.com/sablier-labs/v2-periphery/pull/198))
- Upgrade Solidity to `0.8.21` ([#187](https://github.com/sablier-labs/v2-periphery/pull/187))

### Added

- Add a contract that can batch create streams without a proxy
  ([#177](https://github.com/sablier-labs/v2-periphery/pull/177))
- Add `MerkleStreamer` contract for the LockupLinear model
  ([#174](https://github.com/sablier-labs/v2-periphery/pull/174),
  [#186](https://github.com/sablier-labs/v2-periphery/pull/186) and
  [#190](https://github.com/sablier-labs/v2-periphery/pull/190))
- Add `withdrawMultiple` in targets ([#160](https://github.com/sablier-labs/v2-periphery/pull/160))
- Implement a push-based model for the proxy target ([#173](https://github.com/sablier-labs/v2-periphery/pull/173))
- Implement a proxy target with approvals ([#161](https://github.com/sablier-labs/v2-periphery/pull/161))

### Removed

- **Breaking**: Remove `ProxyPlugin` and `Archive` contracts
  ([#213](https://github.com/sablier-labs/v2-periphery/pull/213))
- Remove `@openzeppelin/contracts` from Node.js peer dependencies
  ([#194](https://github.com/sablier-labs/v2-periphery/pull/194))

## [1.0.3] - 2023-08-17

### Changed

- Bump `@sablier/v2-core` to v1.0.2 ([#164](https://github.com/sablier-labs/v2-periphery/pull/164))
- Update `@prb/proxy` and `@sablier/v2-core` import paths to use `src`
  ([#164](https://github.com/sablier-labs/v2-periphery/pull/164))

## [1.0.2] - 2023-07-13

_No bytecode changes_.

### Changed

- Bump `@sablier/v2-core` to v1.0.1

## [1.0.1] - 2023-07-11

_No bytecode changes_.

### Changed

- Change `permit2` remapping to `@uniswap/permit2`
- Improve wording in NatSpec comments
- Bump `prb-proxy` to v4.0.1

## [1.0.0] - 2023-07-07

### Added

- Initial release
