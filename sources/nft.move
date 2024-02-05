/* 
    This quest features a Non Fungible Token (NFT) module. The module allows the collection manager 
    to mint NFTs and withdraw NFT sales, allows users to combine two NFTs into a new NFT and burn 
    NFTs.

    Collection manager
        The collection manager is the owner of the MinterCap object. The collection manager can mint
        NFTs and withdraw NFT sales.

    Minting NFTs
        In this module, NFTs are minted by the manager of the collection. Minting an NFT requires a
        payment of 1 SUI, which is sent to the MinterCap object. Any change is returned to the 
        sender of the transaction. The NFT is then transferred to the recipient. The NFT is 
        represented by the NonFungibleToken object.

    Combining NFTs
        Anyone that owns two or more NFTS can combine two NFTs into a new NFT. The two NFTs are 
        deleted and a new NFT is created and returned to the sender of the transaction. The new NFT 
        is represented by the NonFungibleToken object.

        When combining two NFTs, the name of the new NFT is the concatenation of the names of the
        two NFTs. For example, 
            - NFT1 name: "NFT1"
            - NFT2 name: "NFT2"
            - New NFT name: "NFT1 + NFT2"
        
        The description of the new NFT is as follows: 
            - "Combined NFT of " + NFT1 name + " and " + NFT2 name

        For example, 
            - NFT1 name: "NFT1"
            - NFT2 name: "NFT2"
            - New NFT description: "Combined NFT of NFT1 and NFT2"

        The new NFT image url will be provided by the sender of the transaction.

    Burning NFTs
        Anyone that owns an NFT can burn it. The NFT is deleted.

    Withdrawing NFT sales
        THe collection manager can withdraw the sales balance from the MinterCap object. The sales
        balance is the total amount of SUI that has been paid for NFTs. 

    Public Getters
        The module provides public getters for the name, description and image of an NFT. This can 
        be called by anyone on any existing NFT.
*/
// Define the NonFungibleToken struct to represent an NFT
resource struct NonFungibleToken {
    owner: address,
    name: string,
    description: string,
    image_url: string,
}

// Define the MinterCap resource to track sales balance
resource struct MinterCap {
    sales_balance: u64,
}

// Define the NFTManager module
module NFTManager {
    // Public function to mint an NFT
    public fun mint_nft(recipient: address, name: string, description: string, image_url: string) acquires MinterCap {
        // Charge 1 SUI to mint an NFT
        0x1::SUI::withdraw(sender, 1);

        // Create and move the NFT to the recipient
        let nft = NonFungibleToken {
            owner: recipient,
            name: name,
            description: description,
            image_url: image_url,
        };
        0x1::NFT::save(move(recipient), move(nft));

        // Update sales balance
        MinterCap::update_sales_balance(1);
    }

    // Public function to combine two NFTs into a new NFT
    public fun combine_nfts(nft1: &NonFungibleToken, nft2: &NonFungibleToken, new_name: string, new_image_url: string): NonFungibleToken {
        // Delete the original NFTs
        0x1::NFT::remove(move(nft1));
        0x1::NFT::remove(move(nft2));

        // Create a new NFT with combined information
        let new_nft = NonFungibleToken {
            owner: sender,
            name: new_name,
            description: "Combined NFT of " + nft1.name + " and " + nft2.name,
            image_url: new_image_url,
        };

        // Move the new NFT to the sender
        0x1::NFT::save(move(sender), move(new_nft));
    }

    // Public function to withdraw sales balance
    public fun withdraw_sales() acquires MinterCap {
        // Ensure the sender is the collection manager
        0x1::MinterCap::ensure_manager(sender);

        // Get and reset the sales balance
        let sales_balance = MinterCap::get_and_reset_sales_balance();

        // Move the sales balance to the sender
        0x1::SUI::deposit(move(sender), move(sales_balance));
    }
}
