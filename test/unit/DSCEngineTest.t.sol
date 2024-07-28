// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth,,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    //////////////////////////////////
    ////Constructor Tests      //////
    ////////////////////////////////
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        DSCEngine engine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
    }

    ///////////////////////////
    ////Price Tests      //////
    /////////////////////////

    function testGetUsdValue() public view {
        uint256 ethAmount = 15e18;
        uint256 expectedUsd = 30000e18;

        uint256 actualUsd = engine.getUsdValue(weth, ethAmount);

        assertEq(expectedUsd, actualUsd);
    }

    function testGetTokenAmountFromUsd() public view {
        uint256 usdAmount = 100 ether;
        // $2000 / Eth, $100
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = engine.getTokenAmountFromUsd(weth, usdAmount);

        assertEq(expectedWeth, actualWeth);
    }

    ///////////////////////////////////
    ////Deposit Collateral      //////
    /////////////////////////////////
    function testRevertsIfCollateralZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.depositeCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN", "RAN", USER, STARTING_ERC20_BALANCE);
        vm.startPrank(USER);

        vm.expectRevert(DSCEngine.DSCEngine__NotAllowedToken.selector);
        engine.depositeCollateral(address(ranToken), AMOUNT_COLLATERAL);
    }

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), AMOUNT_COLLATERAL);
        engine.depositeCollateral(weth, AMOUNT_COLLATERAL);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);

        uint256 expectedTotalDscMinted = 0;
        uint256 expectedCollateralValueInUsd = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);

        assertEq(totalDscMinted, expectedTotalDscMinted);
        assertEq(AMOUNT_COLLATERAL, expectedCollateralValueInUsd);
    }

    function testDscMinted() public depositedCollateral {
        vm.startPrank(USER);
        (, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
        uint256 collateralValue = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        uint256 expectedDscMinted = collateralValue / 2;

        engine.mintDsc(expectedDscMinted);
        (uint256 totalDscMinted,) = engine.getAccountInformation(USER);
        console.log(totalDscMinted);
        assertEq(totalDscMinted, expectedDscMinted);
        vm.stopPrank();
    }

    function testDscMintFailForOverMint() public depositedCollateral {
        vm.startPrank(USER);
        (, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);

        vm.expectRevert(DSCEngine.DSCEngine__BreaksHealthFactor.selector);
        engine.mintDsc(collateralValueInUsd);

        vm.stopPrank();
    }

    ///////////////////////////////////
    ////redeem  Collateral      //////
    /////////////////////////////////
    function testRedeemCollateralForDsc() public depositedCollateral {
        vm.startPrank(USER);
        (, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
        uint256 collateralValue = engine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        uint256 expectedDscMinted = collateralValue / 2;

        engine.mintDsc(expectedDscMinted);
        engine.redeemCollateralForDsc(weth, collateralValue / 8, expectedDscMinted / 2);
        (uint256 totalDscMinted,) = engine.getAccountInformation(USER);
        console.log(totalDscMinted);
        assertEq(totalDscMinted, expectedDscMinted);
        vm.stopPrank();
    }
}
