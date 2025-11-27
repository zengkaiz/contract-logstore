import { network } from "hardhat";

const { ethers } = await network.connect();

const RedPacket = await ethers.getContractFactory("RedPacket");
const redPacket = await RedPacket.deploy();

await redPacket.waitForDeployment();

console.log("RedPacket deployed at:", await redPacket.getAddress());
