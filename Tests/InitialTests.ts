import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";
import { FractionalAllowanceStablecoin } from "../typechain-types";

describe("FractionalAllowanceStablecoin", function () {
  let token: FractionalAllowanceStablecoin;
  let deployer: any;
  let governor: any;
  let minter: any;
  let other: any;

  const initialSupply = ethers.parseUnits("1000000", 18);
  const initialFractionInBps = 100; // 1%

  beforeEach(async function () {
    console.log("Running beforeEach hook");
    [deployer, governor, minter, other] = await ethers.getSigners();

    const FASToken = await ethers.getContractFactory("FractionalAllowanceStablecoin");
    token = await FASToken.deploy(
      "FractionalAllowanceStablecoin",
      "FAST",
      initialSupply,
      deployer.address,
      governor.address,
      minter.address,
      initialFractionInBps
    ) as FractionalAllowanceStablecoin;

    await (token as unknown as Contract).deployed();
    console.log("Contract deployed");
  });

  it("Only MINTER_ROLE can mint", async function () {
    console.log("Running test case for MINTER_ROLE");
    await expect(token.connect(other).mint(other.address, ethers.parseUnits("1", 18)))
      .to.be.revertedWith("AccessControl: account " + other.address.toLowerCase() + " is missing role " + ethers.keccak256(ethers.toUtf8Bytes("MINTER_ROLE")));

    await token.connect(minter).mint(minter.address, ethers.parseUnits("1", 18));
    expect(await token.balanceOf(minter.address)).to.equal(ethers.parseUnits("1", 18));
  });
});