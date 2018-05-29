pragma solidity ^0.4.11;

//OLD Constructor PARAMS
//uint256 _costOfItem, address _buyerAddress, uint256 _costOfEscrow

/*Test values used in Constructor in place of our future parameters from centralized DB
1,"0x080B17d1040ea685D7df33c3864c2c175a68A40e", 1, 1 
1,"0x1fff3a552efbD541A153F9a6fDf344Ff1e7Be1c5", 1, 1
1,"0x3482E39e679C07438D7b9574513760CD1034aEb9", 1, 1
*/

contract ConfirmationFirst {
    address buyerAddress;
    uint256 buyerEscrow;
    bool buyerMadePayment; 
    uint256 finalCostForBuyer;

    address sellerAddress;
    uint256 sellerEscrow;
    
    uint256 costOfItem; //Cost of Item in Wei's 
    uint256 costOfEscrow; //buyerEscrow + sellerEscrow
    uint256 finalCostOfItem; //costOfItem + costOfEscrow
  
    uint256 currentBlock; //block the contract was deployed on the chain
    uint256 expirationBlock; //16sec block's x 259200 seconds
    
    bool buyerAgreePayout = false; //flags that both parties must agree to allow payout of the tx to happen
    bool sellerAgreePayout = false;
    
    //Modifier's
    modifier onlySeller {
        require(msg.sender == sellerAddress);
        _;
    }
    
     modifier onlyBuyer {
        require(msg.sender == buyerAddress);
        _;
    }
    
    //Events  buyerMadePayment,SellerMadePayment,BothAgreedToPayout
    
    
      //Constructor
    function ConfirmationFirst() {
        sellerAddress = msg.sender;
        currentBlock = block.number;
        expirationBlock = currentBlock + 16200;
    }
    
    function()   {
        
    }

    //Getter's 
    function getBuyerAddress() public constant returns(address) {
        return(buyerAddress);
    }
    
    function getSellerAddress() public constant returns(address) {
        return(sellerAddress);
    }
    
    function getAllContractDetails() public constant returns(uint256,address,uint256,uint256) {
        return(costOfItem,buyerAddress,buyerEscrow,sellerEscrow);
    }
    
    function setContractDetails(uint256 _costOfItem, address _buyerAddress, uint256 _buyerEscrow, uint256 _sellerEscrow) public payable {
        buyerAddress = _buyerAddress;
        costOfItem = _costOfItem*10**18;
        buyerEscrow =  _buyerEscrow*10**18;
        sellerEscrow = _sellerEscrow*10**18;
        finalCostForBuyer = costOfItem + buyerEscrow; 
        checkIfSellerMadeEscrowPayment(sellerEscrow);
    }
    
    // If seller did not make the proper escrow payment // Throw
    function checkIfSellerMadeEscrowPayment(uint256 _sellerEscrow) private {
        if (msg.value  != _sellerEscrow) {
            revert();
        } else {
            
        }
    }
    
    // need to check if buyer made payment within timeframe (3 days)
    function refundSeller() onlySeller {
        if (block.number > expirationBlock) {
            selfdestruct(sellerAddress);
        } else {
            
        }
    }
    
    function buyerMakePayment(uint256 paymentAmount) external onlyBuyer payable {
       if (paymentAmount*10**18 == finalCostForBuyer) {
           buyerMadePayment = true;
       } else {
           revert();
       }
       
    }
    
    function iAgreeToPayout()  {
       if (buyerAddress == msg.sender) {
           buyerAgreePayout = true;
           releaseFunds();
       } else if (sellerAddress == msg.sender) {
           sellerAgreePayout = true;

           releaseFunds();
       } else {

       }
    }
    
    function releaseFunds() payable {
        if (sellerAgreePayout == true && buyerAgreePayout == true) {
            buyerAddress.transfer(buyerEscrow);
            selfdestruct(sellerAddress);
        } else {

        }
    }
    
}