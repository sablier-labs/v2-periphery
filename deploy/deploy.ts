import { Addressable } from "ethers";
import hre from "hardhat";
import { Deployer } from "@matterlabs/hardhat-zksync";
import { Wallet, Provider } from "zksync-ethers";

export default async function () {
  const network = await hre.network.config;
  const networkName = await hre.network.name;
  const chainId = Number(network.chainId);

  const provider = new Provider(hre.network.config.url);
  const deployerAddressPV = new Wallet(process.env.PV_KEY as string).connect(provider);
  const deployerAddress = deployerAddressPV.address;

  if (!deployerAddress) {
    console.error("Please set the PV_KEY in your .env file");
    return;
  }

  console.table({
    contract: "SablierV2BatchLockup & SablierV2MerkleLockupFactory",
    chainId: chainId,
    network: networkName,
    deployerAddress: deployerAddress,
  });

  const deployer = new Deployer(hre, deployerAddressPV);

  const artifactBatch = await deployer.loadArtifact("SablierV2BatchLockup");
  const artifactMerkleFactory = await deployer.loadArtifact("SablierV2MerkleLockupFactory");

  const batch = await deployer.deploy(artifactBatch, []);
  const batchAddress = batch.target.toString();
  console.log("SablierV2BatchLockup deployed to:", batchAddress);
  await verifyContract(batchAddress, []);

  const merkleFactory = await deployer.deploy(artifactMerkleFactory, []);
  const merkleFactoryAddress = merkleFactory.target.toString();
  console.log("SablierV2MerkleLockupFactory deployed to:", merkleFactoryAddress);
  await verifyContract(merkleFactoryAddress, []);
}

const verifyContract = async (contractAddress: string | Addressable, verifyArgs: string[]): Promise<boolean> => {
  console.log("\nVerifying contract...");
  await new Promise((r) => setTimeout(r, 20000));
  try {
    await hre.run("verify:verify", {
      address: contractAddress.toString(),
      constructorArguments: verifyArgs,
      noCompile: true,
    });
  } catch (e) {
    console.log(e);
  }
  return true;
};
