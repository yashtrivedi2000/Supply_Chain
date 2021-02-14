// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.4;

import './Product.sol';
import './RawMaterialProviderRole.sol';
import './ResearcherRole.sol';
import './ManufacturerRole.sol';
import './DistributerRole.sol';
import './ConsumerRole.sol';
import './ShippingAnamolyDetectorRole.sol';

contract SupplyChain is Product, 
                        RawMaterialProviderRole, 
                        ResearcherRole, 
                        ManufacturerRole, 
                        DistributerRole, 
                        ConsumerRole,
                        ShippingAnamolyDetectorRole
                        {
    address owner;
    uint upc; //Universal Product Code to identify product
    uint sku; //Stock Keeping Unit

    mapping (uint => Item) items;

    mapping (uint => Txblocks) itemHistory;

    uint[] producedItems;

    enum State {

        ProducedByRawMaterialProvider,
        ForSaleByRawMaterialProvider,
        PurchasedByResearcher,
        ShippedByRawMaterialProvider,
        
        ReceivedByResearcher,
        ProcessedByResearcher,
        PackedByResearcher,
        ForSaleByResearcher,
        PurchasedByManufacturer,
        ShippedByResearcher,
        
        ReceivedByManufacturer,
        ProcessedByManufacturer,
        PackedByManufacturer,
        ForSaleByManufacturer,
        PurchasedByDistributer,
        ShippedByManufacturer,
        
        ReceivedByDistributer,
        ProcessedByDistributer,
        PackedByDistributer,
        ForSaleByDistributer,
        PurchasedByCustomer,
        ShippedByDistributer,

        ReceivedByCustomer
    }

    State constant defaultState = State.ProducedByRawMaterialProvider;

    struct Item {
        uint upc;
        uint sku;
        uint pid;
        uint productPrice;
        
        string itemName;

        bool splitted;
        address splliterAddress;
        uint parentUpc;

        State itemState;                                                // Current State of item

        address ownerId;                                                // Current Owner
        
        address originRawMaterialProviderId;                            // Original Owner
        string rawMaterialProviderName;
        string rawMaterialProviderAddress;
        string rawMaterialProviderDetails;
        uint256 rawMaterialOnSellDate;
        uint256 rawMaterialRecordDate;                                 // Date when added to blockchain
        string notes;
        uint maxTemp;
        uint minTemp;
        string conditions;

        address researcherId;
        string researcherName;
        string researcherAddress;
        string researcherDetails;
        uint256 rawMaterialPurchaseDate;
        uint256 researchItemOnSellDate;
        string researchRemarks;

        address manufacturerId;
        string manufacturerName;
        string manufacturerAddress;
        string manufacturerDetails;
        uint256 researchedItemPurchaseDate;
        uint256 manufacturedItemSellDate;
        string manufaturerRemarks;

        address distributerId;
        string distributerName;
        string distributerAddress;
        string distributerDetails;
        uint256 manufacturedItemPurchasedDate;
        uint256 distributedItemSellDate;
        string distributerRemark;

        address customerId;
        string customerName;
        string customerAddress;
        string customerDetails;
        uint256 distributedItemPurchasedDate;

        bool anamolyDetected;
    }

    struct Txblocks {
        uint RTR;
        uint RTM;
        uint MTD;
        uint DTC;
    }

    event ProducedByRawMaterialProvider (uint upc);
    event ForSaleByRawMaterialProvider (uint upc);
    event PurchasedByResearcher (uint upc);
    event ShippedByRawMaterialProvider (uint upc);
    event ReceivedByResearcher (uint upc);
    event ProcessedByResearcher (uint upc);
    event PackedByResearcher (uint upc);
    event ForSaleByResearcher (uint upc);
    event PurchasedByManufacturer (uint upc);
    event ShippedByResearcher (uint upc);
    event ReceivedByManufacturer (uint upc);
    event ProcessedByManufacturer (uint upc);
    event PackedByManufacturer (uint upc);
    event ForSaleByManufacturer (uint upc);
    event PurchasedByDistributer (uint upc);
    event ShippedByManufacturer (uint upc);
    event ReceivedByDistributer (uint upc);
    event ProcessedByDistributer (uint upc);
    event PackedByDistributer (uint upc);
    event ForSaleByDistributer (uint upc);
    event PurchasedByCustomer (uint upc);
    event ShippedByDistributer (uint upc);
    event ReceivedByCustomer (uint upc);
    event AnamolyDetected (uint upc);

    modifier onlyOwner() override {
        require(msg.sender == owner);
        _;
    }

    modifier verifyCaller (address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint _price) {
        require(msg.value >= _price);
        _;
    }
    
    //Checks the price and refunds the remaining balance
    modifier checkValue(uint _upc, address payable addressToFund) {
        uint _price = items[_upc].productPrice;
        uint  amountToReturn = msg.value - _price;
        addressToFund.transfer(amountToReturn);
        _;
    }

    // Item State Modifiers
    modifier producedByRawMaterialProvider(uint _upc) {
        require(items[_upc].itemState == State.ProducedByRawMaterialProvider);
        _;
    }

    modifier forSaleByRawMaterialProvider(uint _upc) {
        require(items[_upc].itemState == State.ForSaleByRawMaterialProvider);
        _;
    }

    modifier purchasedByResearcher(uint _upc) {
        require(items[_upc].itemState == State.PurchasedByResearcher);
        _;
    }

    modifier shippedByRawMaterialProvider(uint _upc) {
        require(items[_upc].itemState == State.ShippedByRawMaterialProvider);
        _;
    }

    modifier receivedByResearcher(uint _upc) {
        require(items[_upc].itemState == State.ReceivedByResearcher);
        _;
    }

    modifier processedByResearcher(uint _upc) {
        require(items[_upc].itemState == State.ProcessedByResearcher);
        _;
    }

    modifier packedByResearcher(uint _upc) {
        require(items[_upc].itemState == State.PackedByResearcher);
        _;
    }

    modifier forSaleByResearcher(uint _upc) {
        require(items[_upc].itemState == State.ForSaleByResearcher);
        _;
    }

    modifier purchasedByManufacturer(uint _upc) {
        require(items[_upc].itemState == State.PurchasedByManufacturer);
        _;
    }

    modifier shippedByResearcher(uint _upc) {
        require(items[_upc].itemState == State.ShippedByResearcher);
        _;
    }

    modifier receivedByManufacturer(uint _upc) {
        require(items[_upc].itemState == State.ReceivedByManufacturer);
        _;
    }
    
    modifier processedByManufacturer(uint _upc) {
        require(items[_upc].itemState == State.ProcessedByManufacturer);
        _;
    }

    modifier packedByManufacturer(uint _upc) {
        require(items[_upc].itemState == State.PackedByManufacturer);
        _;
    }
    
    modifier forSaleByManufacturer(uint _upc) {
        require(items[_upc].itemState == State.ForSaleByManufacturer);
        _;
    }

    modifier purchasedByDistributer(uint _upc) {
        require(items[_upc].itemState == State.PurchasedByDistributer);
        _;
    }


    modifier shippedByManufacturer(uint _upc) {
        require(items[_upc].itemState == State.ShippedByManufacturer);
        _;
    }

    modifier receivedByDistributer(uint _upc) {
        require(items[_upc].itemState == State.PurchasedByDistributer);
        _;
    }

    modifier processedByDistributer(uint _upc) {
        require(items[_upc].itemState == State.ProcessedByDistributer);
        _;
    }

    modifier packedByDistributer(uint _upc) {
        require(items[_upc].itemState == State.PackedByDistributer);
        _;
    }

    modifier forSaleByDistributer(uint _upc) {
        require(items[_upc].itemState == State.ForSaleByDistributer);
        _;
    }

    modifier purchasedByCustomer(uint _upc) {
        require(items[_upc].itemState == State.PurchasedByCustomer);
        _;
    }

    modifier shippedByDistributer(uint _upc) {
        require(items[_upc].itemState == State.ShippedByDistributer);
        _;
    }

    modifier receivedByCustomer(uint _upc) {
        require(items[_upc].itemState == State.ReceivedByCustomer);
        _;
    }
    
    constructor() payable {
        owner = msg.sender;
        sku = 1;
        upc = 1;
    }

    function kill() public {
        if (msg.sender == owner) {
            address payable ownerAddressPayable = _make_payable(owner);
            selfdestruct(ownerAddressPayable);
        }
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function ProductProducedByRawMaterialProvider ( uint _upc,
                                                    uint _productPrice,
                                                    string memory _name,
                                                    string memory _address,
                                                    string memory _details,
                                                    string memory _notes,
                                                    uint _maxTemp,
                                                    uint _minTemp,
                                                    string memory _conditions,
                                                    string memory item_name
        ) public 
        // onlyRawMaterialProvider()
    {
        Item memory newproduce;
        newproduce.sku = sku;
        newproduce.upc = _upc;
        newproduce.ownerId = msg.sender;
        newproduce.pid = _upc+sku;
        newproduce.productPrice = _productPrice;
        newproduce.itemName = item_name;
        newproduce.itemState = defaultState;
        newproduce.originRawMaterialProviderId = msg.sender;
        newproduce.rawMaterialProviderName = _name;
        newproduce.rawMaterialProviderAddress = _address;
        newproduce.rawMaterialProviderDetails = _details;
        newproduce.rawMaterialRecordDate = block.timestamp;
        newproduce.researcherId = address(0);
        newproduce.researcherName = "";
        newproduce.manufacturerId = address(0);
        newproduce.manufacturerName = "";
        newproduce.distributerId = address(0);
        newproduce.distributerName = "";
        newproduce.customerId = address(0);
        newproduce.customerName = "";
        newproduce.notes = _notes;
        newproduce.maxTemp = _maxTemp;
        newproduce.minTemp = _minTemp;
        newproduce.conditions = _conditions;
        newproduce.anamolyDetected = false;
        items[_upc] = newproduce;
        producedItems.push(_upc);
        sku = sku+1;

        emit ProducedByRawMaterialProvider(_upc);
    }

    function ProductForSaleByRawMaterialProvider (uint _upc, uint _date) public 
    // onlyRawMaterialProvider()
    // producedByRawMaterialProvider(_upc)
    // verifyCaller(items[_upc].ownerId)
    {
        items[_upc].rawMaterialOnSellDate = _date;
        items[_upc].itemState = State.ForSaleByRawMaterialProvider;
        emit ForSaleByRawMaterialProvider(_upc);
    }

    function ProductPurchasedByResearcher (uint _upc,
                                            string memory _name,
                                            string memory _address,
                                            string memory _details,
                                            uint256 _date
    ) public payable
    onlyResearcher()
    forSaleByRawMaterialProvider(_upc)
    paidEnough(items[_upc].productPrice)
    checkValue(_upc, msg.sender)
    {
        address payable ownerAddressPayable = _make_payable(items[_upc].originRawMaterialProviderId);
        ownerAddressPayable.transfer(items[_upc].productPrice);
        items[_upc].ownerId = msg.sender;
        items[_upc].itemState = State.PurchasedByResearcher;
        items[_upc].researcherId = msg.sender;
        items[_upc].researcherName = _name;
        items[_upc].researcherAddress = _address;
        items[_upc].researcherDetails = _details;
        items[_upc].rawMaterialPurchaseDate = _date;
        itemHistory[_upc].RTR = block.number;
        
        emit PurchasedByResearcher(_upc);
    }

    function ProductShippedByRawMaterialProvider (uint _upc) public payable 
    onlyRawMaterialProvider()
    purchasedByResearcher(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.PurchasedByResearcher;
        emit ShippedByRawMaterialProvider(_upc);
    }

    function ProductReceivedByResearcher (uint _upc) public 
    onlyResearcher()
    shippedByRawMaterialProvider(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ReceivedByResearcher;
        emit ReceivedByResearcher(_upc);
    }

    function ProductProcessedByResearcher (uint _upc, string memory _remark) public 
    onlyResearcher()
    receivedByResearcher(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ProcessedByResearcher; // update state
        items[_upc].researchRemarks = _remark;
        emit ProcessedByResearcher(_upc);
    }

    function ProductPackedByResearcher (uint _upc) public 
    onlyResearcher()
    processedByResearcher(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.PackedByResearcher;
        emit PackedByResearcher(_upc);
    }

    function ProductForSaleByResearcher (uint _upc, uint _price, uint256 _date) public 
    onlyResearcher()
    packedByResearcher(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ForSaleByResearcher;
        items[_upc].productPrice = _price;
        items[_upc].researchItemOnSellDate = _date;
        emit ForSaleByResearcher(_upc);

    }

    function ProductPurchasedByManufacturer (uint _upc,
                                            string memory _name,
                                            string memory _address,
                                            string memory _details,
                                            uint256 _date
    ) public payable
    onlyManufacturer()
    forSaleByResearcher(_upc)
    paidEnough(items[_upc].productPrice)
    checkValue(_upc, msg.sender)
    {
        address payable ownerAddressPayable = _make_payable(items[_upc].researcherId);
        ownerAddressPayable.transfer(items[_upc].productPrice);
        items[_upc].ownerId = msg.sender;
        items[_upc].itemState = State.PurchasedByManufacturer;
        items[_upc].manufacturerId = msg.sender;
        items[_upc].manufacturerName = _name;
        items[_upc].manufacturerAddress = _address;
        items[_upc].manufacturerDetails = _details;
        items[_upc].researchedItemPurchaseDate = _date;
        itemHistory[_upc].RTM = block.number;
        emit PurchasedByManufacturer(_upc);

    }

    function ProductShippedByResearcher (uint _upc) public 
    onlyResearcher()
    purchasedByManufacturer(_upc)
    verifyCaller(items[_upc].researcherId)
    {
        items[_upc].itemState = State.ShippedByResearcher;
        emit ShippedByResearcher(_upc);
    }

    function ProductReceivedByManufacturer (uint _upc) public 
    onlyManufacturer()
    shippedByResearcher(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ReceivedByManufacturer;
        emit ReceivedByManufacturer(_upc);
    }

    function ProductProcessedByManufacturer (uint _upc, string memory _remarks) public 
    onlyManufacturer()
    receivedByManufacturer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ProcessedByManufacturer;
        items[_upc].manufaturerRemarks = _remarks;
        emit ProcessedByManufacturer(_upc);
    }

    function ProductPackedByManufacturer (uint _upc) public 
    onlyManufacturer()
    processedByManufacturer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.PackedByManufacturer;
        emit PackedByManufacturer(_upc);
    }

    function ProductForSaleByManufacturer (uint _upc, uint _price, uint256 _date) public 
    onlyManufacturer()
    packedByManufacturer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ForSaleByManufacturer;
        items[_upc].productPrice = _price;
        items[_upc].manufacturedItemSellDate = _date;
        emit ForSaleByManufacturer(_upc);
    }

    function ProductPurchasedByDistributer (uint _upc,
                                            string memory _name,
                                            string memory _address,
                                            string memory _details,
                                            uint256 _date
    ) public payable
    onlyDistributer()
    forSaleByManufacturer(_upc)
    paidEnough(items[_upc].productPrice)
    checkValue(_upc, msg.sender)
    {
        address payable ownerAddressPayable = _make_payable(items[_upc].manufacturerId);
        ownerAddressPayable.transfer(items[_upc].productPrice);
        items[_upc].ownerId = msg.sender;
        items[_upc].itemState = State.PurchasedByDistributer;
        items[_upc].distributerId = msg.sender;
        items[_upc].distributerName = _name;
        items[_upc].distributerAddress = _address;
        items[_upc].distributerDetails = _details;
        items[_upc].manufacturedItemPurchasedDate = _date;
        itemHistory[_upc].MTD = block.number;
        emit PurchasedByDistributer(_upc);
    }

    function ProductShippedByManufacturer (uint _upc) public 
    onlyManufacturer()
    purchasedByDistributer(_upc)
    verifyCaller(items[_upc].manufacturerId)
    {
        items[_upc].itemState = State.ShippedByManufacturer;
        emit ShippedByManufacturer(_upc);
    }

    function ProductReceivedByDistributer (uint _upc) public 
    onlyDistributer()
    shippedByManufacturer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ReceivedByDistributer;
        emit ReceivedByDistributer(_upc);
    }

    function ProductProcessedByDistributer (uint _upc, string memory _remarks) public 
    onlyDistributer()
    receivedByDistributer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ProcessedByDistributer;
        items[_upc].distributerRemark = _remarks;
        emit ProcessedByDistributer(_upc);
    }

    function ProductPackedByDistributer (uint _upc) public 
    onlyDistributer()
    processedByDistributer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.PackedByDistributer;
        emit PackedByDistributer(_upc);
    }

    function ProductForSaleByDistributer (uint _upc, uint _price, uint256 _date) public 
    onlyDistributer()
    packedByDistributer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ForSaleByDistributer;
        items[_upc].productPrice = _price;
        items[_upc].distributedItemSellDate = _date;
        emit ForSaleByDistributer(_upc);
    }

    function ProductPurchasedByCustomer (uint _upc,
                                        string memory _name,
                                        string memory _address,
                                        string memory _details,
                                        uint256 _date
    ) public payable
    onlyConsumer()
    forSaleByDistributer(_upc)
    paidEnough(items[_upc].productPrice)
    checkValue(_upc, msg.sender)
    {
        address payable ownerAddressPayable = _make_payable(items[_upc].distributerId);
        ownerAddressPayable.transfer(items[_upc].productPrice);
        items[_upc].ownerId = msg.sender;
        items[_upc].itemState = State.PurchasedByCustomer;
        items[_upc].customerId = msg.sender;
        items[_upc].customerName = _name;
        items[_upc].customerAddress = _address;
        items[_upc].customerDetails = _details;
        items[_upc].distributedItemPurchasedDate = _date;
        itemHistory[_upc].DTC = block.number;
        emit PurchasedByCustomer(_upc);
    }

    function ProductShippedByDistributer (uint _upc) public 
    onlyDistributer()
    purchasedByCustomer(_upc)
    verifyCaller(items[_upc].distributerId)
    {
        items[_upc].itemState = State.ShippedByDistributer;
        emit ShippedByDistributer(_upc);
    }

    function ProductReceivedByCustomer (uint _upc) public 
    onlyConsumer()
    shippedByDistributer(_upc)
    verifyCaller(items[_upc].ownerId)
    {
        items[_upc].itemState = State.ReceivedByCustomer;
        emit ReceivedByCustomer(_upc);
    }

    function registerAnamoly(uint _upc) public 
    onlyShippingAnamolyDetector()
    {
        items[_upc].anamolyDetected = true;

        emit AnamolyDetected(_upc);
    }

    function fetchitemHistory(uint _upc) public view returns
    (
      uint blockRawMaterialProviderToResearcher,
      uint blockResearcherToManufacturer,
      uint blockManufacturerToDistributer,
      uint blockDistributerToCustomer
    )
    {
      // Assign value to the parameters
      Txblocks memory txblock = itemHistory[_upc];
      return
      (
        txblock.RTR,
        txblock.RTM,
        txblock.MTD,
        txblock.DTC
      );

    }

    function fetchItemInfo1(uint _upc) public view returns
    (
    uint    itemUPC,
    uint    itemSKU,
    uint    productID,
    uint    productPrice,
    State   itemState,
    address ownerId,
    address originRawMaterialProviderId,
    string memory Itemame
    
    )
    {
      // Assign values to the 9 parameters
    Item memory item = items[_upc];

    return
    (
      item.upc,
      item.sku,
      item.pid,
      item.productPrice,
      item.itemState,
      item.ownerId,
      item.originRawMaterialProviderId,
      item.itemName
    );

  }

function fetchItemInfo2(uint _upc) public view returns
    (
    uint    itemUPC,
    string memory RawMaterialProviderName,
    string memory researcherName,
    string memory manufacturerName,
    string memory distributorName,
    string memory customerName
    
    )
    {
      // Assign values to the 9 parameters
    Item memory item = items[_upc];

    return
    (
      item.upc,
      item.rawMaterialProviderName,
      item.researcherName,
      item.manufacturerName,
      item.distributerName,
      item.customerName
    );

  }

  function showAllProduced() public view returns (uint[] memory itemId) {
      return producedItems;
  }


}