# Decentralized Stable Coin (DSC) Protocol

## Introduction

The DSC Protocol is a decentralized finance (DeFi) protocol designed to create a decentralized stablecoin (DSC) that is algorithmically pegged to the US Dollar (USD). Users can mint DSC by storing collateral and burn it to release the collateral. The protocol supports exogenous collateral types, specifically Ethereum (ETH) and Bitcoin (BTC).

## Features

- **Decentralized Stablecoin**: The DSC is algorithmically pegged to the USD.
- **Collateralized Minting**: Users can mint DSC by depositing collateral (ETH or BTC) and burn DSC to release their collateral.
- **Chainlink Price Feeds**: Reliable and tamper-proof price feeds are used to determine the value of collateral assets.
- **OpenZeppelin**: Secure and audited smart contract libraries are used for contract and token creation.

## Architecture

### Contracts

1. **DSC**: The ERC20 token representing the stablecoin.
2. **DSCEngine**: The core engine that handles minting and burning of DSC by managing collateral.

### Collateral

The protocol accepts the following types of collateral:

- Ethereum (ETH)
- Bitcoin (BTC)

### Price Feeds

The protocol relies on Chainlink price feeds to fetch the current market prices of ETH and BTC.

## Getting Started

### Prerequisites

- Foundry
- Chainlink
- OpenZeppelin

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/fraolb/Defi_protocol.git
   cd Defi_protocol
   ```

2. Install dependencies:

   ```bash
   forge install ...
   ```

3. Compile the contracts:

   ```bash
   forge build
   ```

### Deployment

To deploy the DSC protocol to a local blockchain, run:

```bash
forge script/DeployDSC.s.sol
```

### Testing

To run tests, use:

```bash
forge test
```

## Usage

### Minting DSC

To mint DSC, users need to deposit collateral (ETH or BTC) to the `DSCEngine` contract. The amount of DSC minted will be determined by the value of the collateral deposited.

### Burning DSC

To burn DSC and release the collateral, users need to send DSC to the `DSCEngine` contract. The collateral will be released back to the user in proportion to the amount of DSC burned.

## Security

The DSC protocol uses OpenZeppelin libraries to ensure the security and reliability of smart contracts. Chainlink price feeds provide secure and accurate market data for collateral valuation.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

## Contact

For any questions or inquiries, please contact us at [fraolbereket@gmail.com](mailto:fraolbereket@gmail.com).
