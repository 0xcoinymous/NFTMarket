const NFTCreator = artifacts.require("NFTCreator");
const NFTMarket = artifacts.require("NFTMarket");


module.exports = function (deployer) {

  deployer.deploy(NFTMarket).then(function () {
      return deployer.deploy(NFTCreator, NFTMarket.address);
  });
};