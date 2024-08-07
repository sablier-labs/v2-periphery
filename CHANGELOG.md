# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Common Changelog](https://common-changelog.org).

[1.2.0]: https://github.com/sablier-labs/v2-periphery/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/sablier-labs/v2-periphery/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/sablier-labs/v2-periphery/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/sablier-labs/v2-periphery/releases/tag/v1.0.0

## [1.2.0] - 2024-07-04

### Changed

- Bump dependencies ([#283](https://github.com/sablier-labs/v2-periphery/pull/283),
  [#351](https://github.com/sablier-labs/v2-periphery/pull/351),
  [#363](https://github.com/sablier-labs/v2-periphery/pull/363))
- Rename `Batch` to `BatchLockup` ([#322](https://github.com/sablier-labs/v2-periphery/pull/322))
- Rename `MerkleStreamer` to `MerkleLockup` ([#268](https://github.com/sablier-labs/v2-periphery/pull/268))
- Refactor `Range` to `Timestamps` ([#335](https://github.com/sablier-labs/v2-periphery/pull/335))
- Switch to Bun ([#249](https://github.com/sablier-labs/v2-periphery/pull/249))
- Use Solidity v0.8.26 ([#351](https://github.com/sablier-labs/v2-periphery/pull/351))

### Added

- And `BatchLockup` support for `LockupTranched` ([#300](https://github.com/sablier-labs/v2-periphery/pull/300))
- Add grace period mechanism for `clawback` function ([#340](https://github.com/sablier-labs/v2-periphery/pull/340))
- Add `MerkleLockup` support for `LockupTranched` ([#297](https://github.com/sablier-labs/v2-periphery/pull/297),
  [#357](https://github.com/sablier-labs/v2-periphery/pull/357))
- Add `precompiles` in the NPM release ([#302](https://github.com/sablier-labs/v2-periphery/pull/302))

### Removed

- **Breaking**: Remove protocol fee check in `MerkleLL` ([#257](https://github.com/sablier-labs/v2-periphery/pull/257))

## [1.1.1] - 2023-12-20

### Changed

- Upgrade to V2 Core v1.1.2 ([#244](https://github.com/sablier-labs/v2-periphery/pull/244))
- Use Solidity v0.8.23 ([#244](https://github.com/sablier-labs/v2-periphery/pull/244))

## [1.1.0] - 2023-12-17

### Changed

- **Breaking** Upgrade to V2 Core v1.1.1 ([#191](https://github.com/sablier-labs/v2-periphery/pull/191),
  [#236](https://github.com/sablier-labs/v2-periphery/pull/236))
- Refactor import paths to use Node.js dependencies([#236](https://github.com/sablier-labs/v2-periphery/pull/236))
- Use Solidity v0.8.21 ([#187](https://github.com/sablier-labs/v2-periphery/pull/187))

### Added

- Add a contract that can batch create streams without a proxy
  ([#177](https://github.com/sablier-labs/v2-periphery/pull/177))
- Add `MerkleStreamer` contract for the `LockupLinear` model
  ([#174](https://github.com/sablier-labs/v2-periphery/pull/174),
  [#186](https://github.com/sablier-labs/v2-periphery/pull/186) and
  [#190](https://github.com/sablier-labs/v2-periphery/pull/190))

### Removed

- **Breaking**: Remove proxy architecture ([#213](https://github.com/sablier-labs/v2-periphery/pull/213) and
  [#226](https://github.com/sablier-labs/v2-periphery/pull/226))
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
