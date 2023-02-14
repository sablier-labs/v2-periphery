// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.18 <0.9.0;

import { UD2x18, ud2x18 } from "@prb/math/UD2x18.sol";
import { Broker, LockupPro } from "@sablier/v2-core/types/DataTypes.sol";

import { CreateLinear, CreatePro } from "src/types/DataTypes.sol";

import { Constants } from "./Constants.t.sol";

contract Utils is Constants {
    /*//////////////////////////////////////////////////////////////////////////
                            CONSTANT INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /* /// @dev Helper function to return an array of `CreatePro.DeltasParams` that is not "storage ref".
    function defaultDeltasParams() internal view returns (CreatePro.DeltasParams[] memory) {
        CreatePro.DeltasParams[] memory params = new CreatePro.DeltasParams[](PARAMS_COUNT);
        for (uint256 i = 0; i < PARAMS_COUNT; ++i) {
            params[i] = DEFAULT_DELTAS_PARAMS[i];
        }
        return params;
    }
*/
    /// @dev Helper function to return an array of `CreateLinear.DurationsParams` that is not "storage ref".
    function defaultDurationsParams() internal view returns (CreateLinear.DurationsParams[] memory) {
        CreateLinear.DurationsParams[] memory params = new CreateLinear.DurationsParams[](PARAMS_COUNT);
        for (uint256 i = 0; i < PARAMS_COUNT; ++i) {
            params[i] = CreateLinear.DurationsParams({
                amount: DEFAULT_AMOUNT,
                broker: Broker({ account: users.broker, fee: DEFAULT_BROKER_FEE }),
                cancelable: true,
                durations: DEFAULT_DURATIONS,
                recipient: users.recipient,
                sender: users.sender
            });
        }
        return params;
    }

    /// @dev Helper function to return an array of `CreatePro.MilestonesParams` that is not "storage ref".
    function defaultMilestonesParams() internal view returns (CreatePro.MilestonesParams[] memory) {
        CreatePro.MilestonesParams[] memory params = new CreatePro.MilestonesParams[](PARAMS_COUNT);

        for (uint256 i = 0; i < PARAMS_COUNT; ++i) {
            params[i] = CreatePro.MilestonesParams({
                amount: DEFAULT_AMOUNT,
                broker: Broker({ account: users.broker, fee: DEFAULT_BROKER_FEE }),
                cancelable: true,
                recipient: users.recipient,
                segments: defaultSegments(),
                sender: users.sender,
                startTime: DEFAULT_START_TIME
            });
        }

        return params;
    }

    /// @dev Helper function to return an array of `CreateLinear.RangeParams` that is not "storage ref".
    function defaultRangeParams() internal view returns (CreateLinear.RangeParams[] memory) {
        CreateLinear.RangeParams[] memory params = new CreateLinear.RangeParams[](PARAMS_COUNT);

        for (uint256 i = 0; i < PARAMS_COUNT; ++i) {
            params[i] = CreateLinear.RangeParams({
                amount: DEFAULT_AMOUNT,
                broker: Broker({ account: users.broker, fee: DEFAULT_BROKER_FEE }),
                cancelable: true,
                range: DEFAULT_LINEAR_RANGE,
                recipient: users.recipient,
                sender: users.sender
            });
        }

        return params;
    }

    function defaultSegments() internal view returns (LockupPro.Segment[] memory) {
        LockupPro.Segment[] memory segments = new LockupPro.Segment[](2);

        segments[0] = LockupPro.Segment({
            amount: 2_500e18,
            exponent: ud2x18(3.14e18),
            milestone: DEFAULT_START_TIME + DEFAULT_CLIFF_DURATION
        });

        segments[1] = LockupPro.Segment({
            amount: 2_500e18,
            exponent: ud2x18(3.14e18),
            milestone: DEFAULT_START_TIME + DEFAULT_CLIFF_DURATION
        });

        return segments;
    }
}
