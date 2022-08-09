
// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}



interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Staking is  Ownable,ReentrancyGuard {

    //store rewards 
     //claim rewardS
    // calculate price based on pair reserves
    uint256 public lockDuration;
    mapping (address => uint256) public holderUnlockTime;
    mapping (address => uint256) public userInfo;
    mapping (address => uint256) public rewardAmounts;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    IBEP20 public rewardToken;
    IBEP20 public stakingToken;

    uint256 public totalStaked;
    address public pairAddress;

    constructor(
    ) {
        stakingToken = IBEP20(0x43c7BF973Dd82e536d8F6EA9562d8Fdf876Ca707);
        rewardToken = IBEP20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        lockDuration = 30 days;
    }


    // Stake primary tokens
    function depositone() public nonReentrant {
        uint256 _amount = getTokenPrice();
        if(holderUnlockTime[msg.sender] == 0){
            holderUnlockTime[msg.sender] = block.timestamp + lockDuration;
        }
        uint256 amountTransferred = 0;
        if(_amount > 0) {
            uint256 initialBalance = stakingToken.balanceOf(address(this));
            stakingToken.transferFrom(address(msg.sender), address(this), _amount);
            amountTransferred = stakingToken.balanceOf(address(this)) - initialBalance;
            userInfo[msg.sender] = userInfo[msg.sender]+amountTransferred;
            totalStaked += amountTransferred;
        }
        
        emit Deposit(msg.sender, _amount);
    }

    function deposithalf() public nonReentrant {
        uint256 _amount = getTokenPrice()/2;
        if(holderUnlockTime[msg.sender] == 0){
            holderUnlockTime[msg.sender] = block.timestamp + lockDuration;
        }
        uint256 amountTransferred = 0;

        if(_amount > 0) {
            uint256 initialBalance =stakingToken.balanceOf(address(this));
            stakingToken.transferFrom(address(msg.sender), address(this), _amount);
            amountTransferred = stakingToken.balanceOf(address(this)) - initialBalance;
            userInfo[msg.sender] = userInfo[msg.sender]+amountTransferred;
            totalStaked += amountTransferred;
        }
        
        emit Deposit(msg.sender, _amount);
    }

    function withdraw() public nonReentrant {

        require(holderUnlockTime[msg.sender] <= block.timestamp, "May not do normal withdraw early");
        
        uint256 _amount = userInfo[msg.sender];
        
        if(_amount > 0) {
            userInfo[msg.sender] = 0;
            totalStaked -= _amount;
            stakingToken.transfer(address(msg.sender), _amount);

            if(rewardAmounts[address(msg.sender)]>0 && rewardToken.balanceOf(address(this))> rewardAmounts[address(msg.sender)]){
                rewardToken.transfer(address(msg.sender), rewardAmounts[address(msg.sender)]);
                rewardAmounts[address(msg.sender)]=0;
            }
        }
        
        if(userInfo[msg.sender]==0){
            holderUnlockTime[msg.sender] = 0;
        }

        emit Withdraw(msg.sender, _amount);
    }

    //return tokens qty for 1 eth
    function getTokenPrice() internal view returns(uint)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        IBEP20 token1 = IBEP20(pair.token1());
        (uint Res0, uint Res1,) = pair.getReserves();

        // decimals
        uint res0 = Res0*(10**token1.decimals());
        return((res0)/(Res1)); 
    }

    function getDisplayTokenPrice() public view returns(uint)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        IBEP20 token1 = IBEP20(pair.token1());
        IBEP20 token0 = IBEP20(pair.token0());
        (uint Res0, uint Res1,) = pair.getReserves();

        // decimals
        uint res0 = Res0*(10**token1.decimals());
        return((res0)/(Res1*(10**token0.decimals()))); 
    }

    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        rewardToken.transfer(address(msg.sender), _amount);
    }

    function updateRewardToken(address _rewardToken) external onlyOwner {
        rewardToken=IBEP20(_rewardToken);
    }

    function updatePairAddress(address _pairAddress) external onlyOwner {
        pairAddress=_pairAddress;
    }

    function updateRewardAmount(address[] calldata addresses, uint256[] calldata amounts) external onlyOwner {

        require(addresses.length < 801,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
        require(addresses.length == amounts.length,"Mismatch between Address and token count");

        for(uint i=0; i < addresses.length; i++){  
            rewardAmounts[addresses[i]]=amounts[i];
        }
    }

   

}