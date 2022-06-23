pragma solidity >=0.4.22 ;

contract shopanddraw
{
    
    //得獎者
    address public winner;
    //賣家位址
    address public selleradr;
    //抽獎陣列
    address [] private _purchaser; 
    //商品名稱
    string public commodityname;
    //賣家名稱
    string public sellername;
    //商品價格
    uint public commodityprice;
    //購買人數記數
    uint public purchasercount;
    //抽獎價格
    uint public winnerprice;
    uint public startTime;
    //是否可以購買
    bool public canpurchase;
    //是否合約結束
    bool public end;
    //購買人結構
    struct purstr
    {
        //購買人位址
        address puradr;
        //購買數量
        uint purnum;
    }


    mapping(uint => purstr) public purchaser;
    
    //只有賣家可使用
    modifier onlyselleradr
    {
        require(msg.sender == selleradr);
        _;
    }

    //輸入價格檢查
    modifier pricecheck
    {
        require(msg.value%(commodityprice * 1 ether) ==0 );
        _;
    }

    //是否可以購買
    modifier open
    {
        require(canpurchase == true);
        _;
    }
    modifier close
    {
        require(canpurchase == false);
        _;
    }
    //本次商品是否結束
    modifier _end
    {
        require(end == false);
        _;
    }

    constructor(string memory _commodityname,string memory _sellername,uint _commodityprice,uint _winnerprice)public
    {
        commodityname = _commodityname;
        sellername = _sellername;
        commodityprice = _commodityprice;
        selleradr = msg.sender;
        winnerprice = _winnerprice;
        startTime = now;
        canpurchase = false;
        end = false;
    }

    //購買
    function purchase(address puradd) public payable open pricecheck
    {   
        uint _purnum = msg.value/(commodityprice * 1 ether);
        for(uint i; i<=_purnum;i++)
        {
            _purchaser.push(puradd);
        }
        purchaser[purchasercount] = purstr({puradr : puradd,purnum : _purnum});
        purchasercount++;
    }

    //開關購買
    function openclose() public onlyselleradr _end
    {
        if(canpurchase == true)
        {
            canpurchase = false;
        }
        else   
        {
            canpurchase = true;
        }
    }

    //抽獎函數
    function random() private view returns (uint)
    { 
        return uint(keccak256(abi.encode(block.difficulty,now,_purchaser)));
    }

    function make_payable(address x) internal pure returns(address payable)
    {
        return address(uint160(x));
    }

    //抽出得獎者，並發出獎勵，同時將收益收回
    function getwinner() public  onlyselleradr close()
    {
        address add = _purchaser[random() % _purchaser.length];
        make_payable(add).transfer(winnerprice* 1 ether);
        make_payable(selleradr).transfer(address(this).balance);
        winner = add;
        end = true;
    }
}