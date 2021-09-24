pragma solidity ^0.5.10;

/// @title Contract for "Countering counterfeits on the Supply Chain with Blockchain"
contract SupplyChain {
    
    
    /// @dev nummanufacturers: Number of manufacturers
    /// @dev numsellers: Number of sellers 
    /// @dev numcustomers: Number of customers
    /// @dev numbanks: Number of banks
    /// @dev numregulators: Number of regulatory bodies
    /// @dev xlist: list of x where x = {seller, customer, manufacturer, bank}
    /// @dev awaitingApproval: List of products not yet approved by the regulatory bodies
    /// @dev approved: List of products approved by the regulatory bodies
    
     uint256 nummanufacturers;
     uint256 numsellers;
     uint256 numcustomers;
     uint256 numregulators;
     uint256 numbanks;
     uint256 [] exproductids;
     address [] manufacturerlist;
     address [] sellerlist;
     address [] customerlist;
     address [] regulatorlist;
     address [] banklist;
     uint256 [] awaitingApproval;
     uint256 [] approved;
     
     mapping(address => uint) pendingReturns;
     
     /// @dev exist: Boolean which tells the validity of the Regulatory body
     struct Regulator{
          bool exist;
     }
     /// @dev exist: Boolean which tells the validity of the Bank
     struct Bank{
          bool exist;
     }
     
     /// @dev id: Manufacturer's unique id
     /// @dev productids: List of products the manufacturer produces
     
     struct Manufacturer{
         uint256 id;
         bool exist;
         uint256 [] productids;
    }
     /// @dev productid: id of the product
     /// @dev buyerAddress: Address of the buyer who's made purchase for it
     /// @dev exchange: Boolean which tells if the Transaction for that product is validated
     /// @dev price: The amount for which product sells
    struct Product{
         uint256 productid;
         address buyerAddress;
         bool exchange;
         uint256 price;
    }
     /// @dev numproducts: Number of products the seller is authorized to take order for
     /// @dev Product: List of products
     /// @dev exist: Boolean which tells if the Seller is validated
    struct Seller{
         mapping (uint256 => uint256) idquantity;
         uint256 numproducts;
         Product [] products;
         bool exist;
    }
     /// @dev sellerAddress: Address of the seller
     /// @dev price: Amount willing to pay for the product
     /// @dev productid: ID of product the customer wants to buy
     /// @dev exist: Boolean which tells if the customer is validated    
    struct Customer{
         bool exist;
         uint256 productid;
         address sellerAddress;
         uint256 price;
         string signedhash;
    }
    
    mapping (address => Manufacturer) manufacturers;
    mapping (address => Seller) sellers;
    mapping (address => Customer) customers;
    mapping (address => Regulator) regulators;
    mapping (address => Bank) banks;
    
    /// @notice constructor initializes to default values
    constructor() public {
         nummanufacturers=0;
         numsellers=0;
         numcustomers=0;
         numregulators=0;
         numbanks=0;
    }
    
    /// @notice Function to add Manufacturer to the network
    function joinmanufacturer() public {
         require(manufacturers[msg.sender].exist == false, "This manufacturer is already registered.");
         nummanufacturers+=1;
         Manufacturer storage info = manufacturers[msg.sender];
         if (info.productids.length == 0){
            info.productids = new uint32 [](5);
         }
         info.exist=true;
         manufacturerlist.push(msg.sender);
    }
    
    /// @notice Function to add seller to the network. Can be called by the manufacturer
    /// @param selleradr: Seller's address
    function joinseller(address selleradr) public {
         require(manufacturers[msg.sender].exist == true, "Not a Valid Manufacturer");
         require(sellers[selleradr].exist == false, "This seller is already registered.");
         numsellers+=1;
         Seller storage info = sellers[selleradr];
         /* if (info.products.length == 0){
            info.products = new Product [](100);
         } */
         info.exist=true;
         info.numproducts=0;
         sellerlist.push(selleradr);
    }
    
    /// @notice Function to add customer to the network
    function joincustomer() public {
         require(customers[msg.sender].exist == false, "This Customer is already registered.");
         numsellers+=1;
         Customer storage info = customers[msg.sender];
         info.exist=true;
         customerlist.push(msg.sender);
    }

    /// @notice Function to add Regulatory Body to the network
    function joinregulator() public {
         require(regulators[msg.sender].exist == false, "This Regulator already exists.");
         numregulators+=1;
         Regulator storage info = regulators[msg.sender];
         info.exist=true;
         regulatorlist.push(msg.sender);
    }
    
    /// @notice Function to add Bank to the network
    function joinbank() public {
         require(banks[msg.sender].exist == false, "This Bank already exists.");
         numbanks+=1;
         Bank storage info = banks[msg.sender];
         info.exist=true;
         banklist.push(msg.sender);
    }

    /// @notice Function to avail loans from the bank
    /// @param manufactureraddress: Address of the loan taker
    function loan(address manufactureraddress) public payable{
         require(banks[msg.sender].exist == true, "This user is not authorized for this action");
         pendingReturns[manufactureraddress]+=msg.value;
    }
    
    /// @notice Function to add a new product
    /// @param productid: Id of the product to be added
    function addproductid(uint256 productid) public {
         require(manufacturers[msg.sender].exist == true, "Not a Valid Manufacturer");
         bool flag=false;
         for(uint256 i=0; i<exproductids.length; i++){
              if(exproductids[i]==productid){
                   flag=true;
                   break;
              }
         }
         require(flag == false, "ProductID already exists");
         exproductids.push(productid);
         awaitingApproval.push(productid);
         manufacturers[msg.sender].productids.push(productid);
    }
    
    /// @notice Function to approve product by the regulatory body
    /// @param productid: Id pf the product awaiting approval
    function approve(uint256 productid) public {
         require(regulators[msg.sender].exist == true, "This user is not authorized for this action");
         bool flag=false;
         for(uint256 i=0; i<approved.length; i++){
              if(approved[i]==productid){
                   flag=true;
                   break;
              }
         }
         require(flag == false, "This product has already been approved");
         flag=false;
         for(uint256 i=0; i<awaitingApproval.length; i++){
              if(awaitingApproval[i]==productid){
                   awaitingApproval[i]=0;
                   flag=true;
                   break;
              }
         }
         require(flag == true, "This product does not exist");
         approved.push(productid);
    }
    
    /// @notice Function to specify quantity of product to be sold for a specific seller
    /// @param productid: ID of the product
    /// @param numproducts: Available quantity of the product
    /// @param selleradr: Address of the seller
    function declarequantity(uint256 productid, uint256 numproducts, address selleradr) public {
         require(manufacturers[msg.sender].exist == true, "Not a Valid Manufacturer");
         require(sellers[selleradr].exist == true, "Not a Valid Seller");
         bool flag=false;
         for(uint256 i=0; i<approved.length; i++){
              if(approved[i]==productid){
                   flag=true;
              }
         }
         require(flag == true, "This product is not authorized for sale");
         flag=false;
         for(uint256 i=0; i<manufacturers[msg.sender].productids.length; i++){
              if(manufacturers[msg.sender].productids[i]==productid){
                   flag=true;
              }
         }
         require(flag == true, "Manufacturer does not manufacture that ProductID");
         sellers[selleradr].idquantity[productid]+=numproducts;
    }

    /// @notice Function to update the values in Product struct
    /// @param productid: ID of the product
    /// @param price: Price for which the product is selling
    /// @param buyerAddress: Address of the buyer
    function setproductseller(uint256 productid, uint256 price, address buyerAddress) public{
         require(sellers[msg.sender].exist == true, "Not a Valid Seller");
         require(customers[buyerAddress].exist == true, "Not a Valid Customer");
         require(sellers[msg.sender].idquantity[productid]>0, "This Seller does not sell this product or this product is sold out");
         Seller storage info = sellers[msg.sender];
         Product memory p;
         info.products.push(p);
         sellers[msg.sender].idquantity[productid]-=1;
         sellers[msg.sender].products[sellers[msg.sender].numproducts].productid=productid;
         sellers[msg.sender].products[sellers[msg.sender].numproducts].price=price;
         sellers[msg.sender].products[sellers[msg.sender].numproducts].buyerAddress=buyerAddress;
         sellers[msg.sender].products[sellers[msg.sender].numproducts].exchange=false;
         sellers[msg.sender].numproducts+=1;

    }
    
    /// @notice Function to update customer struct values
    /// @param productid: ID of the product
    /// @param price: Price for the product 
    /// @param selleradr: Address of the seller
    function setproductcustomer(uint256 productid, uint256 price, address selleradr) public{
         require(sellers[selleradr].exist == true, "Not a Valid Seller");
         require(customers[msg.sender].exist == true, "Not a Valid Customer");
         customers[msg.sender].productid=productid;
         customers[msg.sender].sellerAddress=selleradr;
         customers[msg.sender].price=price;
    }
    /// @notice Function sign the message 
    /// @param messagehash: Hash of the message that needs to be sent
    /// @param buyerAddressr: Address of the buyer
    function createSign(string memory messagehash, address buyerAddress) public{
         require(customers[buyerAddress].exist == true, "Not a Valid Customer");
         require(sellers[msg.sender].exist == true, "Not a Valid Seller");
         customers[buyerAddress].signedhash=messagehash;
    }
    
    /// @notice Function to verify the recieved message
    /// @param v: Components recovered by slicing
    /// @param r: Components recovered by slicing
    /// @param s: Components recovered by slicing
    /// @param msgHash: Hash of the message recieved
    function verifyhash(bytes32 r, bytes32 s, bytes1 v, bytes32 msgHash) public payable{
         require(customers[msg.sender].exist == true, "Not a Valid Customer");
         uint8 v_decimal = uint8(v)+27;
         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
         bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, msgHash));
         address unhash = ecrecover(prefixedHash, v_decimal, r, s);
         address selleradr=customers[msg.sender].sellerAddress;
         require(unhash==selleradr,"Invalid Transaction");
         bool flag=false;
         for(uint256 i=0; i<sellerlist.length; i++){
              if(sellerlist[i]==unhash){
                   flag=true;
              }
         }
         require(flag==true,"Not a valid Seller");
         uint256 cusproductid=customers[msg.sender].productid;
         uint256 cusprice=customers[msg.sender].price;
         bool flag2=false;
         for(uint256 i=0; i<sellers[selleradr].products.length; i++){
              if(cusproductid==sellers[selleradr].products[i].productid && cusprice == sellers[selleradr].products[i].price && cusprice==msg.value && msg.sender==sellers[selleradr].products[i].buyerAddress){
                   flag2=true;
              }
         }
         require(flag2==true,"This is not a valid purchase");
         pendingReturns[selleradr]+=msg.value;
    }
    
    /// @notice Function to verify the customer
    /// @param v: Components recovered by slicing
    /// @param r: Components recovered by slicing
    /// @param s: Components recovered by slicing
    /// @param msgHash: Hash of the message recieved    
    function verifycustomer(address buyerAddress, bytes32 r, bytes32 s, bytes1 v, bytes32 msgHash) public {
         require(manufacturers[msg.sender].exist == true, "Not a Valid Manufacturer");
         require(customers[buyerAddress].exist == true, "Not a Valid Customer");
         uint8 v_decimal = uint8(v)+27;
         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
         bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, msgHash));
         address unhash = ecrecover(prefixedHash, v_decimal, r, s);
         address selleradr=customers[buyerAddress].sellerAddress;
         require(unhash==buyerAddress,"Invalid Transaction");
         bool flag=false;
         for(uint256 i=0; i<customerlist.length; i++){
              if(customerlist[i]==unhash){
                   flag=true;
              }
         }
         require(flag==true,"Not a valid Seller");
         bool flag2=false;
         uint256 cusproductid=customers[unhash].productid;
         for(uint256 i; i<manufacturers[msg.sender].productids.length; i++){
              if(cusproductid==manufacturers[msg.sender].productids[i]){
                   flag2=true;
              }
         }
         require(flag2==true,"This manufacturer does not sell this product.");
         uint256 cusprice=customers[unhash].price;
         for(uint256 i=0; i<sellers[selleradr].products.length; i++){
              if(cusproductid==sellers[selleradr].products[i].productid && cusprice == sellers[selleradr].products[i].price && buyerAddress==sellers[selleradr].products[i].buyerAddress){
                   sellers[selleradr].products[i].exchange=true;
              }
         }
    }
    
    /// @notice Function to check balance
    function checkBalance() view public returns(uint256 balance){
         return msg.sender.balance;
    }
    /// @notice Function to check balance of the contract
    function checkContractBalance() view public returns(uint256 balance){
         return address(this).balance;
    }
    /// @notice Function to facilitate payment of the balance.
    function withdraw() public{
         uint amount = pendingReturns[msg.sender];
         if (amount > 0) {
            /*
            * @dev It is important to set this to zero because the recipient
            * can call this function again as part of the receiving call
            * before `transfer` returns (see the remark above about
            * conditions -> effects -> interaction).
            */
            pendingReturns[msg.sender] = 0;

            msg.sender.transfer(amount);
          }
     }
}
