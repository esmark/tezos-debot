pragma ton-solidity >=0.57.3;

import "./interfaces/Network/Network.sol";
import "./interfaces/Terminal/Terminal.sol";

contract TezosSendContract {
    string constant BASE_URL = "https://rpc.hangzhounet.teztnets.xyz/"; //set test or main Tezos RPC domain
    string from;
    string to;
    uint amount;
    string lastBlock;
    string chainId;
    string managerKey;

    function parseString(string str) public returns (string) {
        uint end = bytes(str).length - 2;
        return str[1:end];
    }

    function sendXtz(string _from, string _to, uint _amount) public {
        from = _from;
        to = _to;
        amount = _amount;
        getLastBlock();
    }

    function getLastBlock() public {
        string[] headers;
        string url = BASE_URL + '/chains/main/blocks/head/hash';
        Network.get(tvm.functionId(setLastBlock), url, headers);
    }

    function setLastBlock(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 101);
        lastBlock = parseString(content);
        Terminal.print(0, format("lastBlock: {}", lastBlock));
        getChainId();
    }

    function getChainId() private {
        string[] headers;
        string url = BASE_URL + '/chains/main/chain_id';
        Network.get(tvm.functionId(setChainId), url, headers);
    }

    function setChainId(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 101);
        chainId = parseString(content);
        Terminal.print(0, format("chainId: {}", chainId));
        getManagerKey();
    }

    function getManagerKey() private {
        string[] headers;
        string url = format("{}/chains/main/blocks/head/context/contracts/{}/manager_key", BASE_URL, from);
        Network.get(tvm.functionId(setManagerKey), url, headers);
    }

    function setManagerKey(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 101);
        managerKey = parseString(content);
        Terminal.print(0, format("managerKey: {}", managerKey));
    }

}
