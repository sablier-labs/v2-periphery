import { ethers, run } from "hardhat";

async function main() {
  const SablierV2BatchLockup = await ethers.getContractFactory("SablierV2BatchLockup");
  const batchLockup = await SablierV2BatchLockup.deploy();

  await batchLockup.deployed();
  console.log("SablierV2BatchLockup deployed to:", batchLockup.address);

  const SablierV2MerkleLockupFactory = await ethers.getContractFactory("SablierV2MerkleLockupFactory");
  const merkleLockupFactory = await SablierV2MerkleLockupFactory.deploy();

  await merkleLockupFactory.deployed();
  console.log("SablierV2MerkleLockupFactory deployed to:", merkleLockupFactory.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
