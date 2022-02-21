pragma ton-solidity >=0.40.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "../../Debot.sol";
import "../../Terminal/Terminal.sol";
import "../Network.sol";

contract Example is Debot {

    function start() public override {
        string[] headers;
        string url = "https://rpc.hangzhounet.teztnets.xyz/chains/main/blocks/head/context/contracts/tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9/balance";
        //headers.push("Content-Type: application/x-www-form-urlencoded");
        //string body = "key1=value1";
        Network.get(tvm.functionId(setResponse), url, headers);
    }

    function setResponse(int32 statusCode, string[] retHeaders, string content) public {
        require(statusCode == 200, 101);
        // TODO: analyze headers.
        for (string hdr: retHeaders) {
            Terminal.print(0, hdr);
        }
        // TODO: deserialize content from json to structure using Json interface.
        Terminal.print(0, content);
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Network.ID];
    }

    function getDebotInfo() public functionID(0xDEB) view override returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon) {
        name = "Network Example";
        version = "0.1.0";
        publisher = "TON Labs";
        key = "Example Debot for Network Interface";
        author = "TON Labs";
        support = address(0);
        hello = "Hello, I'm example DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = "";
    }
}