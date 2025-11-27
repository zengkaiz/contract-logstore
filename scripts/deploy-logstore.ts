import { network } from "hardhat";

const { ethers } = await network.connect();

const LogStore = await ethers.getContractFactory("LogStore");
const logStore = await LogStore.deploy();

await logStore.waitForDeployment();

console.log("LogStore deployed at:", await logStore.getAddress());
