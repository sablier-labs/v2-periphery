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

  const deployer = new Deployer(hre, deployerAddressPV);

  console.table({
    contract: "ZkNationSablierGateway",
    chainId: chainId,
    network: networkName,
    deployerAddress: deployerAddress,
  });

  const artifactZkNationSablierGateway = await deployer.loadArtifact("ZkNationSablierGateway");
  const artifactZkCappedMinter = await deployer.loadArtifact("ZkCappedMinter");

  const zkNationSablierGateway = await deployer.deploy(artifactZkNationSablierGateway, [
    process.env.ADMIN,
    "0x1D68417ff71855Eb0237Ff03a8FfF02Ef67e4AFb",
    "0x69e5DC39E2bCb1C17053d2A4ee7CAEAAc5D36f96",
    "0x6fEB7Ca79CFD7e1CF761c7Aa8659F24e392fbc7D",
  ]);

  const zkNationSablierGatewayAddress = zkNationSablierGateway.target.toString();
  console.log("ZkNationSablierGateway deployed to:", zkNationSablierGatewayAddress);

  console.table({
    contract: "ZkCappedMinter",
    chainId: chainId,
    network: networkName,
    deployerAddress: deployerAddress,
  });

  const zkCappedMinter = await deployer.deploy(artifactZkCappedMinter, [
    "0x69e5DC39E2bCb1C17053d2A4ee7CAEAAc5D36f96",
    zkNationSablierGatewayAddress,
    "100000000000000000000000000",
  ]);

  const zkCappedMinterAddress = zkCappedMinter.target.toString();
  console.log("ZkCappedMinter deployed to:", zkCappedMinterAddress);

  await verifyContract(zkNationSablierGatewayAddress, [
    process.env.ADMIN,
    "0x1D68417ff71855Eb0237Ff03a8FfF02Ef67e4AFb",
    "0x69e5DC39E2bCb1C17053d2A4ee7CAEAAc5D36f96",
    "0x6fEB7Ca79CFD7e1CF761c7Aa8659F24e392fbc7D",
  ]);

  await verifyContract(zkCappedMinterAddress, [
    "0x69e5DC39E2bCb1C17053d2A4ee7CAEAAc5D36f96",
    zkNationSablierGatewayAddress,
    "100000000000000000000000000",
  ]);

  await zkNationSablierGateway.setZkTokenMinter(zkCappedMinterAddress);
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
