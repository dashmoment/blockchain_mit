// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title CLQ Message Board with Fee
/// @notice 使用者可以在鏈上儲存一段字串，並支付 10 CLQ 手續費給本合約
contract CLQMessageBoard is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @dev CLQ 代幣合約地址（你的 ConsensusLiquidate）
    IERC20 public immutable clq;
    /// @dev 若你的 CLQ 支援 ERC20Permit（你有繼承 ERC20Permit），這裡可選用
    IERC20Permit public immutable clqPermit;

    /// @dev 手續費（以最小單位計），預設為 10 * 10^18
    uint256 public fee;

    /// @dev 一筆留言資料
    struct Note {
        address sender;
        string content;
        uint256 timestamp;
    }

    Note[] private _notes;

    /// --------------------
    ///        Events
    /// --------------------
    event MessageStored(uint256 indexed id, address indexed sender, string content, uint256 timestamp);
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event Withdraw(address indexed to, uint256 amount);

    /// --------------------
    ///       Errors
    /// --------------------
    error EmptyMessage();
    error ZeroAddress();
    error InsufficientAllowance();

    /// @param clqToken CLQ 代幣地址（部署過的 ConsensusLiquidate）
    /// @param initialFee 手續費（最小單位，若為 0 則預設 10e18）
    constructor(address clqToken, uint256 initialFee) Ownable(msg.sender) {
        if (clqToken == address(0)) revert ZeroAddress();
        clq = IERC20(clqToken);
        // 若代幣支援 permit，就設定；否則為零地址（permit 函數會失敗）
        clqPermit = IERC20Permit(clqToken);

        fee = initialFee == 0 ? 10 * 10**18 : initialFee;
    }

    /// @notice 以傳統 approve/transferFrom 支付手續費並儲存訊息
    /// @dev 需事先對本合約 approve 至少 `fee`
    function storeMessage(string calldata content) external nonReentrant returns (uint256 id) {
        if (bytes(content).length == 0) revert EmptyMessage();

        // // 檢查 allowance（非必要，但可給更友善的錯誤）
        uint256 allowance_ = clq.allowance(msg.sender, address(this));
        if (allowance_ < fee) revert InsufficientAllowance();

        // // 收取手續費
        clq.safeTransferFrom(msg.sender, address(this), fee);

        // 儲存留言
        id = _pushNote(msg.sender, content);
    }

    /// @notice 使用 ERC20Permit (EIP-2612) 一次交易完成核准與扣款並儲存訊息
    /// @param deadline permit 的最後期限（時間戳）
    /// @param v,r,s 來自簽名的 ECDSA 參數
    function permitAndStore(
        string calldata content,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external nonReentrant returns (uint256 id) {
        if (bytes(content).length == 0) revert EmptyMessage();

        // 對本合約核准 fee，spender 為本合約地址
        clqPermit.permit(msg.sender, address(this), fee, deadline, v, r, s);

        // 收取手續費
        clq.safeTransferFrom(msg.sender, address(this), fee);

        // 儲存留言
        id = _pushNote(msg.sender, content);
    }

    /// @notice 由擁有人提領累積的 CLQ 手續費
    function withdraw(address to, uint256 amount) external onlyOwner nonReentrant {
        if (to == address(0)) revert ZeroAddress();
        clq.safeTransfer(to, amount);
        emit Withdraw(to, amount);
    }

    /// @notice 擁有人調整手續費（單位為代幣最小單位）
    function setFee(uint256 newFee) external onlyOwner {
        emit FeeUpdated(fee, newFee);
        fee = newFee;
    }

    /// @notice 總留言數
    function notesCount() external view returns (uint256) {
        return _notes.length;
    }

    /// @notice 取得特定 id 的留言
    function getNote(uint256 id) external view returns (Note memory) {
        return _notes[id];
    }

    /// @notice 便利查詢：回傳最後一筆留言 id（若沒有留言會 revert）
    function lastNoteId() external view returns (uint256) {
        return _notes.length - 1;
    }

    /// @dev 內部共用：存入留言並發出事件
    function _pushNote(address sender, string calldata content) internal returns (uint256 id) {
        id = _notes.length;
        _notes.push(Note({
            sender: sender,
            content: content,
            timestamp: block.timestamp
        }));
        emit MessageStored(id, sender, content, block.timestamp);
    }

    function checkMyCLQBalance() external view returns (uint256) {
        return clq.balanceOf(msg.sender);
    }

     function checkMyCLQAllowance() external view returns (uint256) {
        return clq.allowance(msg.sender,  address(this));
    }

    function show_msg_sender() public view returns (address){
        return msg.sender;
    }

    function show_current_addr() public view returns (address){
        return address(this);
    }
}