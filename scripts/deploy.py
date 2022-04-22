from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import ( 
    get_account, 
    deploy_mocks, 
    LOCAL_BLOCKCHAIN_ENVIRONMENTS)


from web3 import Web3

def deploy_fund_me():
    account = get_account()
    # Price feed 
    price_feed_address = get_price_feed_address(account)
    # Deploy
    fund_me = FundMe.deploy(
        price_feed_address, 
        {"from": account}, 
        publish_source = config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me

def get_price_feed_address(_account):
    # Show active network
    print(f"The active network is {network.show_active()}")
    # Require statment 
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return config["networks"][network.show_active()]["eth_usd_price_feed_address"]
    # By default apply Mocks 
    return deploy_mocks()

def main():
    deploy_fund_me()